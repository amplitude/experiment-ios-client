//
//  EvaluationEngine.swift
//  Experiment
//
//  Created by Brian Giori on 9/11/23.
//

import Foundation

internal class EvaluationEngine {
    
    struct EvaluationTarget : Selectable {
        let context: [String: Any?]
        var result: [String: EvaluationVariant]
        
        func select(selector: String) -> Any? {
            switch selector {
            case "context": return context
            case "result": return result
            default: return nil
            }
        }
    }
    
    func evaluate(context: [String: Any?], flags: [EvaluationFlag]) -> [String: EvaluationVariant] {
        var results: [String: EvaluationVariant] = [:]
        var target = EvaluationTarget(context: context, result: results)
        for flag in flags {
            if let variant = evaluateFlag(target: target, flag: flag) {
                results[flag.key] = variant
                target.result = results
            }
        }
        return results
    }
    
    private func evaluateFlag(target: EvaluationTarget, flag: EvaluationFlag) -> EvaluationVariant? {
        var result: EvaluationVariant? = nil
        for segment in flag.segments {
            if let segmentResult = evaluateSegment(target: target, flag: flag, segment: segment) {
                // Merge all metadata into the result
                let metadata = mergeMetadata(flag.metadata, segment.metadata, segmentResult.metadata)
                result = EvaluationVariant(key: segmentResult.key, value: segmentResult.value, payload: segmentResult.payload, metadata: metadata)
                break
            }
        }
        return result
    }
    
    private func evaluateSegment(target: EvaluationTarget, flag: EvaluationFlag, segment: EvaluationSegment) -> EvaluationVariant? {
        guard let segmentConditions = segment.conditions else {
            // Null conditions always match
            if let variantKey = bucket(target: target, segment: segment) {
                return flag.variants[variantKey]
            } else {
                return nil
            }
        }
        // Outer logic is "or" (||)
        for conditions in segmentConditions {
            var match = true
            // Inner list logic is "and" (&&)
            for condition in conditions {
                match = matchCondition(target: target, condition: condition)
                if !match {
                    break
                }
            }
            if match {
                if let variantKey = bucket(target: target, segment: segment) {
                    return flag.variants[variantKey]
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    private func matchCondition(target: EvaluationTarget, condition: EvaluationCondition) -> Bool {
        let propValue = target.select(selector: condition.selector)
        // We need special matching for null properties and set type prop values
        // and operators. All other values are matched as strings, since the
        // filter values are always strings.
        if propValue == nil {
            return matchNull(op: condition.op, filterValues: condition.values)
        } else if (isSetOperator(op: condition.op)) {
            guard let propValueStringList = coerceStringList(value: propValue) else {
                return false
            }
            return matchSet(propValues: propValueStringList, op: condition.op, filterValues: condition.values)
        } else {
            guard let propValueString = coerceString(value: propValue) else {
                return false
            }
            return matchString(propValue: propValueString, op: condition.op, filterValues: condition.values)
        }
    }
    
    private func getHash(key: String) -> Int64 {
        let data = key.data(using: .utf8) ?? Data()
        let hash = data.murmurHash32x86(seed: 0)
        return Int64(hash) & 0xffffffff
    }
    
    private func bucket(target: EvaluationTarget, segment: EvaluationSegment) -> String? {
        // TODO: Implement
        guard let segmentBucket = segment.bucket else {
            // A null bucket means the segment is fully rolled out. Select the default variant.
            return segment.variant
        }
        // Select the bucketing value.
        let bucketingValue = coerceString(value: target.select(selector: segmentBucket.selector))
        // A null or empty bucketing value cannot be bucketed. Select the default variant.
        guard let bucketingValue = bucketingValue else {
            return segment.variant
        }
        if bucketingValue.isEmpty {
            return segment.variant
        }
        // Salt and hash the value, and compute the allocation and distribution values.
        let keyToHash = "\(segmentBucket.salt)/\(bucketingValue)"
        let hash = getHash(key: keyToHash)
        let allocationValue = hash % 100
        let distributionValue = hash / 100
        for allocation in segmentBucket.allocations {
            let allocationStart = Int64(allocation.range[0])
            let allocationEnd = Int64(allocation.range[1])
            if (allocationStart..<allocationEnd).contains(allocationValue) {
                for distribution in allocation.distributions {
                    let distributionStart = Int64(distribution.range[0])
                    let distributionEnd = Int64(distribution.range[1])
                    if (distributionStart..<distributionEnd).contains(distributionValue) {
                        return distribution.variant
                    }
                }
            }
        }
        return segment.variant
    }

    private func matchNull(op: String, filterValues: Set<String>) -> Bool {
        let containsNone = containsNone(filterValues: filterValues)
        switch op {
        case EvaluationOperator.IS, EvaluationOperator.CONTAINS, EvaluationOperator.LESS_THAN,
            EvaluationOperator.LESS_THAN_EQUALS, EvaluationOperator.GREATER_THAN,
            EvaluationOperator.GREATER_THAN_EQUALS, EvaluationOperator.VERSION_LESS_THAN,
            EvaluationOperator.VERSION_LESS_THAN_EQUALS, EvaluationOperator.VERSION_GREATER_THAN,
            EvaluationOperator.VERSION_GREATER_THAN_EQUALS, EvaluationOperator.SET_IS,
            EvaluationOperator.SET_CONTAINS, EvaluationOperator.SET_CONTAINS_ANY: return containsNone
        case EvaluationOperator.IS_NOT, EvaluationOperator.DOES_NOT_CONTAIN,
            EvaluationOperator.SET_DOES_NOT_CONTAIN, EvaluationOperator.SET_DOES_NOT_CONTAIN_ANY: return !containsNone
        case EvaluationOperator.REGEX_MATCH: return false
        case EvaluationOperator.REGEX_DOES_NOT_MATCH, EvaluationOperator.SET_IS_NOT: return true
        default: return false
        }
    }
    
    private func matchSet(propValues: Set<String>, op: String, filterValues: Set<String>) -> Bool {
        switch op {
        case EvaluationOperator.SET_IS: return propValues == filterValues
        case EvaluationOperator.SET_IS_NOT: return propValues != filterValues
        case EvaluationOperator.SET_CONTAINS: return matchesSetContainsAll(propValues: propValues, filterValues: filterValues)
        case EvaluationOperator.SET_DOES_NOT_CONTAIN: return !matchesSetContainsAll(propValues: propValues, filterValues: filterValues)
        case EvaluationOperator.SET_CONTAINS_ANY: return matchesSetContainsAny(propValues: propValues, filterValues: filterValues)
        case EvaluationOperator.SET_DOES_NOT_CONTAIN_ANY: return !matchesSetContainsAny(propValues: propValues, filterValues: filterValues)
        default: return false
        }
    }
    
    private func matchString(propValue: String, op: String, filterValues: Set<String>) -> Bool {
        switch op {
        case EvaluationOperator.IS: return matchesIs(propValue: propValue, filterValues: filterValues)
        case EvaluationOperator.IS_NOT: return !matchesIs(propValue: propValue, filterValues: filterValues)
        case EvaluationOperator.CONTAINS: return matchesContains(propValue: propValue, filterValues: filterValues)
        case EvaluationOperator.DOES_NOT_CONTAIN: return !matchesContains(propValue: propValue, filterValues: filterValues)
        case EvaluationOperator.LESS_THAN, EvaluationOperator.LESS_THAN_EQUALS, EvaluationOperator.GREATER_THAN, EvaluationOperator.GREATER_THAN_EQUALS:
            return matchesComparable(propValue: propValue, op: op, filterValues: filterValues) { value in
                return self.parseDouble(value: value)
            }
        case EvaluationOperator.VERSION_LESS_THAN, EvaluationOperator.VERSION_LESS_THAN_EQUALS, EvaluationOperator.VERSION_GREATER_THAN, EvaluationOperator.VERSION_GREATER_THAN_EQUALS:
            return matchesComparable(propValue: propValue, op: op, filterValues: filterValues) { value in
                return SemanticVersion.parse(version: value)
            }
        case EvaluationOperator.REGEX_MATCH: return matchesRegex(propValue: propValue, filterValues: filterValues)
        case EvaluationOperator.REGEX_DOES_NOT_MATCH: return !matchesRegex(propValue: propValue, filterValues: filterValues)
        default: return false
        }
    }
    
    private func matchesIs(propValue: String, filterValues: Set<String>) -> Bool {
        if containsBooleans(filterValues: filterValues) {
            let lower = propValue.lowercased()
            if lower == "true" || lower == "false" {
                return filterValues.contains { $0.lowercased() == lower }
            }
        }
        return filterValues.contains(propValue)
    }
    
    private func matchesContains(propValue: String, filterValues: Set<String>) -> Bool {
        for filterValue in filterValues {
            if propValue.lowercased().contains(filterValue.lowercased()) {
                return true
            }
        }
        return false
    }
    
    private func matchesComparable<T : Comparable>(propValue: String, op: String, filterValues: Set<String>, transformer: @escaping (String) -> T?) -> Bool {
        let propValueTransformed = transformer(propValue)
        let filterValuesTransformed = filterValues.map(transformer).filter { $0 != nil } as! [T]
        if propValueTransformed == nil || filterValuesTransformed.isEmpty {
            // If the prop value or none of the filter values transform, fall
            // back on string comparison.
            return filterValues.contains { filterValue in
                matchesComparable(propValue: propValue, op: op, filterValue: filterValue)
            }
        } else {
            return filterValuesTransformed.contains { filterValueTransformed in
                matchesComparable(propValue: propValueTransformed!, op: op, filterValue: filterValueTransformed)
            }
        }
    }
    
    private func matchesComparable<T : Comparable>(propValue: T, op: String, filterValue: T) -> Bool {
        switch op {
        case EvaluationOperator.LESS_THAN, EvaluationOperator.VERSION_LESS_THAN: return propValue < filterValue
        case EvaluationOperator.LESS_THAN_EQUALS, EvaluationOperator.VERSION_LESS_THAN_EQUALS: return propValue <= filterValue
        case EvaluationOperator.GREATER_THAN, EvaluationOperator.VERSION_GREATER_THAN: return propValue > filterValue
        case EvaluationOperator.GREATER_THAN_EQUALS, EvaluationOperator.VERSION_GREATER_THAN_EQUALS: return propValue >= filterValue
        default: return false
        }
    }
    
    private func matchesRegex(propValue: String, filterValues: Set<String>) -> Bool {
        return filterValues.contains { filterValue in
            propValue.range(of: filterValue, options: .regularExpression) != nil
        }
    }
    
    private func matchesSetContainsAll(propValues: Set<String>, filterValues: Set<String>) -> Bool {
        if propValues.count < filterValues.count {
            return false
        }
        for filterValue in filterValues {
            if !matchesIs(propValue: filterValue, filterValues: propValues) {
                return false
            }
        }
        return true
    }
    
    private func matchesSetContainsAny(propValues: Set<String>, filterValues: Set<String>) -> Bool {
        for filterValue in filterValues {
            if matchesIs(propValue: filterValue, filterValues: propValues) {
                return true
            }
        }
        return false
    }
    
    private func parseDouble(value: String) -> Double? {
        return Double.init(value)
    }
    
    private func coerceString(value: Any?) -> String? {
        guard let value = value else {
            return nil
        }
        if let stringValue = value as? String {
            return stringValue
        } else if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
            return String(data: jsonData, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    private func coerceStringList(value: Any?) -> Set<String>? {
        guard let value = value else {
            return nil
        }
        // Convert sequences to a set of strings
        if let sequence = value as? NSArray {
            return sequenceToSet(sequence: sequence)
        }
        if let sequence = value as? Array<Any?> {
            return sequenceToSet(sequence: sequence)
        }
        // Parse the string value as a json array and convert to a set of strings
        // or return nil if the string could not be parsed as a json array.
        guard let dataValue = coerceString(value: value)?.data(using: .utf8) else {
            return nil
        }
        if let opt = try? JSONSerialization.jsonObject(with: dataValue) {
            if let nsArray = opt as? NSArray {
                var result = Set<String>()
                for element in nsArray {
                    if let stringElement = coerceString(value: element) {
                        result.insert(stringElement)
                    }
                }
                return result
            }
        }
 
        return nil
    }
    
    private func sequenceToSet(sequence: any Sequence) -> Set<String>? {
        var result = Set<String>()
        for element in sequence {
            if let stringElement = coerceString(value: element) {
                result.insert(stringElement)
            }
        }
        return result
    }
    
    private func containsNone(filterValues: Set<String>) -> Bool {
        return filterValues.contains("(none)")
    }
    
    private func containsBooleans(filterValues: Set<String>) -> Bool {
        return filterValues.contains { filterValue in
            let lower = filterValue.lowercased()
            return lower == "true" || lower == "false"
        }
    }
    
    private func isSetOperator(op: String) -> Bool {
        switch op {
        case EvaluationOperator.SET_IS: return true
        case EvaluationOperator.SET_IS_NOT: return true
        case EvaluationOperator.SET_CONTAINS: return true
        case EvaluationOperator.SET_DOES_NOT_CONTAIN: return true
        case EvaluationOperator.SET_CONTAINS_ANY: return true
        case EvaluationOperator.SET_DOES_NOT_CONTAIN_ANY: return true
        default: return false
        }
    }
    
    private func mergeMetadata(_ m1: [String: Any?]?, _ m2: [String: Any?]?, _ m3: [String: Any?]?) -> [String: Any?]? {
        var mergedMetadata = m1 ?? [:]
        if let m2 = m2 {
            mergedMetadata = mergedMetadata.merging(m2, uniquingKeysWith: { (_, other) in other })
        }
        if let m3 = m3 {
            mergedMetadata = mergedMetadata.merging(m3, uniquingKeysWith: { (_, other) in other })
        }
        if mergedMetadata.count == 0 {
            return nil
        }
        return mergedMetadata
    }
}
