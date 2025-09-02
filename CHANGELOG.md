## [1.18.3](https://github.com/amplitude/experiment-ios-client/compare/v1.18.2...v1.18.3) (2025-09-02)


### Bug Fixes

* specify swift 5 language mode ([#78](https://github.com/amplitude/experiment-ios-client/issues/78)) ([9760637](https://github.com/amplitude/experiment-ios-client/commit/976063700023c0e7d3f180a0ecd04bfef550749a))

## [1.18.2](https://github.com/amplitude/experiment-ios-client/compare/v1.18.1...v1.18.2) (2025-08-22)


### Bug Fixes

* avoid supported version deprecated warning ([#76](https://github.com/amplitude/experiment-ios-client/issues/76)) ([91b1957](https://github.com/amplitude/experiment-ios-client/commit/91b195799f2c99b2835ea799ea32bd693b35b066))

## [1.18.1](https://github.com/amplitude/experiment-ios-client/compare/v1.18.0...v1.18.1) (2025-05-30)


### Bug Fixes

* improve plugin objc interface ([#73](https://github.com/amplitude/experiment-ios-client/issues/73)) ([77ec832](https://github.com/amplitude/experiment-ios-client/commit/77ec8323e723ee941cad9d87e025266ddcba00e5))

# [1.18.0](https://github.com/amplitude/experiment-ios-client/compare/v1.17.0...v1.18.0) (2025-05-14)


### Features

* add core dependency and plugin ([#70](https://github.com/amplitude/experiment-ios-client/issues/70)) ([e384a71](https://github.com/amplitude/experiment-ios-client/commit/e384a71f21fc1a07a8eeaa1eb4bbfed3697f8f82))

# [1.17.0](https://github.com/amplitude/experiment-ios-client/compare/v1.16.1...v1.17.0) (2025-05-13)


### Bug Fixes

* fix deadlock synchronization ([#71](https://github.com/amplitude/experiment-ios-client/issues/71)) ([19ad0b4](https://github.com/amplitude/experiment-ios-client/commit/19ad0b41e0c0a3f5282ed49e957554d815290a4b))
* update analytics connector to 1.3.1 ([5740bd7](https://github.com/amplitude/experiment-ios-client/commit/5740bd73b7f53c66c1a83d6ac067a14dae209fee))


### Features

* add support for visionOS ([#69](https://github.com/amplitude/experiment-ios-client/issues/69)) ([b91e1e0](https://github.com/amplitude/experiment-ios-client/commit/b91e1e0c1da8d2e47f2883ba5b79ad1febc2df5b))

## [1.16.1](https://github.com/amplitude/experiment-ios-client/compare/v1.16.0...v1.16.1) (2025-03-14)


### Bug Fixes

* fix variant experiment key serialization w/ both keys set ([#68](https://github.com/amplitude/experiment-ios-client/issues/68)) ([a62fbc0](https://github.com/amplitude/experiment-ios-client/commit/a62fbc0fa31024c6f63e33361933aa96aa19d1d8))

# [1.16.0](https://github.com/amplitude/experiment-ios-client/compare/v1.15.0...v1.16.0) (2025-01-13)


### Bug Fixes

* add synchronization around the client's user object ([#66](https://github.com/amplitude/experiment-ios-client/issues/66)) ([964616f](https://github.com/amplitude/experiment-ios-client/commit/964616f3812841ff39f170738b74f15e4f7fbf1e))


### Features

* update ios deployment target to 11.0 ([b550e27](https://github.com/amplitude/experiment-ios-client/commit/b550e27002e7a37595a649a9186e3ae85f1eca37))
* update watchos deployment target to 4.0 ([c80f40a](https://github.com/amplitude/experiment-ios-client/commit/c80f40ad40e539c309a2ebbc3417a2bca107a1c6))

# [1.15.0](https://github.com/amplitude/experiment-ios-client/compare/v1.14.0...v1.15.0) (2024-12-03)


### Features

* Update DefaultUserProvider platform and device values ([#65](https://github.com/amplitude/experiment-ios-client/issues/65)) ([9d63b9a](https://github.com/amplitude/experiment-ios-client/commit/9d63b9a39698208ebd3018f169c4a5aef077fe19))

# [1.14.0](https://github.com/amplitude/experiment-ios-client/compare/v1.13.7...v1.14.0) (2024-11-26)


### Features

* increase flag polling interval; add flag poller interval config ([#64](https://github.com/amplitude/experiment-ios-client/issues/64)) ([520123c](https://github.com/amplitude/experiment-ios-client/commit/520123c2d0da7cba9e80b5591f03398abd450cec))

## [1.13.7](https://github.com/amplitude/experiment-ios-client/compare/v1.13.6...v1.13.7) (2024-09-13)


### Bug Fixes

* ensure `completion` block is always called in `DefaultExperimentClient.start` function ([#60](https://github.com/amplitude/experiment-ios-client/issues/60)) ([5f0e1dc](https://github.com/amplitude/experiment-ios-client/commit/5f0e1dc892b5ece649e9a8b4dafaaa854ff38203))

## [1.13.6](https://github.com/amplitude/experiment-ios-client/compare/v1.13.5...v1.13.6) (2024-09-10)


### Bug Fixes

* Make `stop` method public ([#59](https://github.com/amplitude/experiment-ios-client/issues/59)) ([5dd4303](https://github.com/amplitude/experiment-ios-client/commit/5dd4303fca36feedbcd112b9f4444a6d59145ceb))

## [1.13.5](https://github.com/amplitude/experiment-ios-client/compare/v1.13.4...v1.13.5) (2024-05-06)


### Bug Fixes

* toDictionary function should convert Date object to string ([#54](https://github.com/amplitude/experiment-ios-client/issues/54)) ([6ebbc3f](https://github.com/amplitude/experiment-ios-client/commit/6ebbc3fe15b7ef2f16188996aba14f7dbd480bcd))

## [1.13.4](https://github.com/amplitude/experiment-ios-client/compare/v1.13.3...v1.13.4) (2024-04-10)


### Bug Fixes

* Adopt resource bundle for privacy manifest in Cocoapods ([#52](https://github.com/amplitude/experiment-ios-client/issues/52)) ([dc87951](https://github.com/amplitude/experiment-ios-client/commit/dc8795144dac89242ad03fa434be806b60c4630f))

## [1.13.3](https://github.com/amplitude/experiment-ios-client/compare/v1.13.2...v1.13.3) (2024-04-09)


### Bug Fixes

* add privacy manifest ([#48](https://github.com/amplitude/experiment-ios-client/issues/48)) ([ea9ceed](https://github.com/amplitude/experiment-ios-client/commit/ea9ceedfa486e175569f2e5decc10aa70487a8bf))

## [1.13.2](https://github.com/amplitude/experiment-ios-client/compare/v1.13.1...v1.13.2) (2024-03-14)


### Bug Fixes

* experiment user equals user property comparison ([0e66823](https://github.com/amplitude/experiment-ios-client/commit/0e66823e377f5298238657c19e84924ea20d3149))
* explicitly unwrap double optional for swift 4 compilation ([de347f9](https://github.com/amplitude/experiment-ios-client/commit/de347f9c8c68d92c2972d52dbec6f767d8a1e6c4))

## [1.13.1](https://github.com/amplitude/experiment-ios-client/compare/v1.13.0...v1.13.1) (2024-01-29)


### Bug Fixes

* Improve remote evaluation fetch retry logic ([#43](https://github.com/amplitude/experiment-ios-client/issues/43)) ([00f00ef](https://github.com/amplitude/experiment-ios-client/commit/00f00ef72cd2da885d2348fc786ec7903d42f86b))

# [1.13.0](https://github.com/amplitude/experiment-ios-client/compare/v1.12.2...v1.13.0) (2023-12-01)


### Features

* bootstrap initial local evaluation flags ([#41](https://github.com/amplitude/experiment-ios-client/issues/41)) ([7c5c995](https://github.com/amplitude/experiment-ios-client/commit/7c5c995eb8c22331f6b4eb03e56cb283352ceb08))

## [1.12.2](https://github.com/amplitude/experiment-ios-client/compare/v1.12.1...v1.12.2) (2023-11-22)


### Bug Fixes

* fix the translation of legacy variant payloads from storage ([#40](https://github.com/amplitude/experiment-ios-client/issues/40)) ([83c2391](https://github.com/amplitude/experiment-ios-client/commit/83c2391f5c83f0c2468ffc82f9f2c820fdda039e))

## [1.12.1](https://github.com/amplitude/experiment-ios-client/compare/v1.12.0...v1.12.1) (2023-11-09)


### Bug Fixes

* call fetch on start by default ([#38](https://github.com/amplitude/experiment-ios-client/issues/38)) ([66fea3b](https://github.com/amplitude/experiment-ios-client/commit/66fea3bcb771973e28aa4e308c8ca329a7938d4a))

# [1.12.0](https://github.com/amplitude/experiment-ios-client/compare/v1.11.1...v1.12.0) (2023-10-10)


### Bug Fixes

* update analytics-connector; min macos deployment target 10.13 ([46f295e](https://github.com/amplitude/experiment-ios-client/commit/46f295e1b6d02e54913ee77be23402877a29e0d8))


### Features

* local-evaluation ([#36](https://github.com/amplitude/experiment-ios-client/issues/36)) ([ebe1188](https://github.com/amplitude/experiment-ios-client/commit/ebe1188e8cb8103052c17323e5ec050e713679e0))

## [1.11.1](https://github.com/amplitude/experiment-ios-client/compare/v1.11.0...v1.11.1) (2023-09-28)


### Bug Fixes

* include experiment key in exposure event ([9909d21](https://github.com/amplitude/experiment-ios-client/commit/9909d2181031acf09fe402a5f9c3132009f912bb))

# [1.11.0](https://github.com/amplitude/experiment-ios-client/compare/v1.10.0...v1.11.0) (2023-06-02)


### Features

* add experiment key to variant and exposure event ([#34](https://github.com/amplitude/experiment-ios-client/issues/34)) ([0a55ead](https://github.com/amplitude/experiment-ios-client/commit/0a55ead7292d5b6d6805b9b14cc236f21527d006))

# [1.10.0](https://github.com/amplitude/experiment-ios-client/compare/v1.9.2...v1.10.0) (2023-04-24)


### Bug Fixes

* fix the connector user provider when id is set prior to provider init ([#33](https://github.com/amplitude/experiment-ios-client/issues/33)) ([c7a99ef](https://github.com/amplitude/experiment-ios-client/commit/c7a99efd9ceb5bd741102fb122a3b9a0a623143a))


### Features

* add group and group property support to user ([#32](https://github.com/amplitude/experiment-ios-client/issues/32)) ([2ac2330](https://github.com/amplitude/experiment-ios-client/commit/2ac2330c7c833d54510bb5062be37515497fc8fd))

## [1.9.2](https://github.com/amplitude/experiment-ios-client/compare/v1.9.1...v1.9.2) (2023-03-15)


### Bug Fixes

* connector user provider concurrency ([#30](https://github.com/amplitude/experiment-ios-client/issues/30)) ([113fcdc](https://github.com/amplitude/experiment-ios-client/commit/113fcdcf187924f5607da96920dddbe7d91450d9))

## [1.9.1](https://github.com/amplitude/experiment-ios-client/compare/v1.9.0...v1.9.1) (2023-01-20)


### Bug Fixes

* make clear() method public ([#28](https://github.com/amplitude/experiment-ios-client/issues/28)) ([062692d](https://github.com/amplitude/experiment-ios-client/commit/062692d47a9486887cc0285f2880b4d5fc43ec4d))
* update analytics-connector; distribution mode; fix test ([3e8fc62](https://github.com/amplitude/experiment-ios-client/commit/3e8fc6254863aabc5add25229705cfdebd4837b6))

# [1.9.0](https://github.com/amplitude/experiment-ios-client/compare/v1.8.0...v1.9.0) (2022-11-22)


### Features

* add subflag support ([#26](https://github.com/amplitude/experiment-ios-client/issues/26)) ([da12290](https://github.com/amplitude/experiment-ios-client/commit/da122906e19e004252a98c722990777513a884b2))

# [1.8.0](https://github.com/amplitude/experiment-ios-client/compare/v1.7.3...v1.8.0) (2022-10-22)


### Features

* add the flag config Clear method ([#25](https://github.com/amplitude/experiment-ios-client/issues/25)) ([df1c147](https://github.com/amplitude/experiment-ios-client/commit/df1c147f7ba5d7dadd3bf016c370755240e91ffb))

## [1.7.3](https://github.com/amplitude/experiment-ios-client/compare/v1.7.2...v1.7.3) (2022-09-08)


### Bug Fixes

* properly compare ExperimentUser properties ([#24](https://github.com/amplitude/experiment-ios-client/issues/24)) ([9b76fa4](https://github.com/amplitude/experiment-ios-client/commit/9b76fa412d81e0765ea41336aa8aced3bb6b250d))

## [1.7.2](https://github.com/amplitude/experiment-ios-client/compare/v1.7.1...v1.7.2) (2022-08-03)


### Bug Fixes

* increase integration timeout to 10 seconds ([#23](https://github.com/amplitude/experiment-ios-client/issues/23)) ([5f70203](https://github.com/amplitude/experiment-ios-client/commit/5f70203cfef5adb7a704992818c546652ad7052e))

## [1.7.1](https://github.com/amplitude/experiment-ios-client/compare/v1.7.0...v1.7.1) (2022-06-02)


### Bug Fixes

* add secondary initial variants as a fallback ([5ff93a6](https://github.com/amplitude/experiment-ios-client/commit/5ff93a6ed0b5bb328f2e7f0ff3698b1e9a4cc9f6))

# [1.7.0](https://github.com/amplitude/experiment-ios-client/compare/v1.6.0...v1.7.0) (2022-04-15)


### Features

* invalidate exposure cache on user identity change ([#22](https://github.com/amplitude/experiment-ios-client/issues/22)) ([f45d3f4](https://github.com/amplitude/experiment-ios-client/commit/f45d3f4bbab63d3d69fb4d7eec464020da432355))

# [1.6.0](https://github.com/amplitude/experiment-ios-client/compare/v1.5.0...v1.6.0) (2022-02-12)


### Bug Fixes

* update spm package definition with connector pkg ([#20](https://github.com/amplitude/experiment-ios-client/issues/20)) ([96946ae](https://github.com/amplitude/experiment-ios-client/commit/96946aee175577f9dc231d75838969df6b2bd5a8))


### Features

* add exposure tracking provider interface ([#21](https://github.com/amplitude/experiment-ios-client/issues/21)) ([dca2b10](https://github.com/amplitude/experiment-ios-client/commit/dca2b10125faba9014d89482f7a47406c7534605))
* core package integration into experiment sdk ([#17](https://github.com/amplitude/experiment-ios-client/issues/17)) ([caa8dac](https://github.com/amplitude/experiment-ios-client/commit/caa8dac38338c20945716d85a4149a2a6ab29073))
* use renamed connector package instead of core ([#18](https://github.com/amplitude/experiment-ios-client/issues/18)) ([7d90816](https://github.com/amplitude/experiment-ios-client/commit/7d90816082b5b7c0316469c427e3c3894f8a5a1b))

# [1.5.0](https://github.com/amplitude/experiment-ios-client/compare/v1.4.1...v1.5.0) (2021-11-11)


### Bug Fixes

* dont overwrite stored user with empty user on fetch ([#14](https://github.com/amplitude/experiment-ios-client/issues/14)) ([9649662](https://github.com/amplitude/experiment-ios-client/commit/9649662926cbc6456f1fa781fab76d64e22e9d1f))
* fix tests once and for all ([4317be6](https://github.com/amplitude/experiment-ios-client/commit/4317be68ed3582db0d286ba00d493a63d8eef212))
* fix variant equality for object payloads ([#16](https://github.com/amplitude/experiment-ios-client/issues/16)) ([e2471b6](https://github.com/amplitude/experiment-ios-client/commit/e2471b691ca72778114d88fdf8a6b2270634e5fb))
* override description in user and variant objects ([2de4dfd](https://github.com/amplitude/experiment-ios-client/commit/2de4dfd619a1f8db75b5310b745ba8ef437bd8a5))
* unwrap optional when printing variant payload ([0146310](https://github.com/amplitude/experiment-ios-client/commit/014631096a2e436d7f5373342ac4030805b4ec3a))
* update user merge function to use new user props ([45806e2](https://github.com/amplitude/experiment-ios-client/commit/45806e26570f517db22b288cf1c8906c1630d5bf))


### Features

* allow for non-string user property values ([#15](https://github.com/amplitude/experiment-ios-client/issues/15)) ([9879df1](https://github.com/amplitude/experiment-ios-client/commit/9879df1cbdcfbef5095eed48254756a517168a8c))
* Support Objective-C  ([#7](https://github.com/amplitude/experiment-ios-client/issues/7)) ([7f0084a](https://github.com/amplitude/experiment-ios-client/commit/7f0084ae98f37d9fe45f4f72c68ed364d7dbae0b))

## [1.4.1](https://github.com/amplitude/experiment-ios-client/compare/v1.4.0...v1.4.1) (2021-10-27)


### Bug Fixes

* potential crash with concurrent storage map copy and write ([#13](https://github.com/amplitude/experiment-ios-client/issues/13)) ([e9786f0](https://github.com/amplitude/experiment-ios-client/commit/e9786f03bded995790b86add5e1900e597879590))

# [1.4.0](https://github.com/amplitude/experiment-ios-client/compare/v1.3.0...v1.4.0) (2021-10-18)


### Features

* unset user properties when variant evaluates to null or is a fa… ([#12](https://github.com/amplitude/experiment-ios-client/issues/12)) ([63776fa](https://github.com/amplitude/experiment-ios-client/commit/63776fa16c2d626efa61c4c12bfd6ff7501c2a24))

# [1.3.0](https://github.com/amplitude/experiment-ios-client/compare/v1.2.1...v1.3.0) (2021-08-12)


### Features

* add user properties to exposure event ([#10](https://github.com/amplitude/experiment-ios-client/issues/10)) ([6c77b1e](https://github.com/amplitude/experiment-ios-client/commit/6c77b1ecbe888d455367f1e8714dfe3e70ad6d77))

## [1.2.1](https://github.com/amplitude/experiment-ios-client/compare/v1.2.0...v1.2.1) (2021-08-10)


### Bug Fixes

* use config user provider ([1e4a05c](https://github.com/amplitude/experiment-ios-client/commit/1e4a05c2e0b93d0bec65d09275dca6a44e4fc96b))

# [1.2.0](https://github.com/amplitude/experiment-ios-client/compare/v1.1.2...v1.2.0) (2021-07-29)


### Bug Fixes

* revert post to get with header ([#9](https://github.com/amplitude/experiment-ios-client/issues/9)) ([17b14cd](https://github.com/amplitude/experiment-ios-client/commit/17b14cd7f3e96eebf0b57b0474d908ba84dbd0b2))
* use post instead of get for fetch ([#6](https://github.com/amplitude/experiment-ios-client/issues/6)) ([3a56e7d](https://github.com/amplitude/experiment-ios-client/commit/3a56e7d550f08c5aea83042b3a0afbf3583ae934))


### Features

* exposure tracking through analytics provider ([#8](https://github.com/amplitude/experiment-ios-client/issues/8)) ([10f08e9](https://github.com/amplitude/experiment-ios-client/commit/10f08e9f7d63fdcaa8f1ea07f042449e0b771138))

## [1.1.2](https://github.com/amplitude/experiment-ios-client/compare/v1.1.1...v1.1.2) (2021-07-01)


### Bug Fixes

* dont force unwrap ([2276624](https://github.com/amplitude/experiment-ios-client/commit/2276624871fef4cf4c6627dd2684cebc02930a65))

## [1.1.1](https://github.com/amplitude/experiment-ios-client/compare/v1.1.0...v1.1.1) (2021-07-01)


### Bug Fixes

* variant encoding/decoding from storage ([#5](https://github.com/amplitude/experiment-ios-client/issues/5)) ([713e475](https://github.com/amplitude/experiment-ios-client/commit/713e4757b77d22a8cabba06703871559b7058bc5))

# [1.1.0](https://github.com/amplitude/experiment-ios-client/compare/v1.0.2...v1.1.0) (2021-06-28)


### Features

* add automatic background retries to fetch ([#3](https://github.com/amplitude/experiment-ios-client/issues/3)) ([8fc3d98](https://github.com/amplitude/experiment-ios-client/commit/8fc3d9802aafdabde1ef4c08eb6dbd0f88f5a9c0))
* set DefaultUserProvider by default ([#4](https://github.com/amplitude/experiment-ios-client/issues/4)) ([fa49ef3](https://github.com/amplitude/experiment-ios-client/commit/fa49ef37adf5aee03a7868d8c8d9b7d6d0ec7ea8))

## [1.0.2](https://github.com/amplitude/experiment-ios-client/compare/v1.0.1...v1.0.2) (2021-06-09)


### Bug Fixes

* remove amplitude as dependency ([713a9b8](https://github.com/amplitude/experiment-ios-client/commit/713a9b832ca5783ff1dd7edd6a7d38ef1920826d))

## [1.0.1](https://github.com/amplitude/experiment-ios-client/compare/v1.0.0...v1.0.1) (2021-06-09)


### Bug Fixes

* remove Amplitude as dependency for SPM ([#1](https://github.com/amplitude/experiment-ios-client/issues/1)) ([5ac6beb](https://github.com/amplitude/experiment-ios-client/commit/5ac6beb9f3de8cd08b715266466744462be1f75b))

# [1.0.0](https://github.com/amplitude/experiment-ios-client/compare/v0.3.0...v1.0.0) (2021-06-03)


### Bug Fixes

* remove old changelogs ([b11ba5e](https://github.com/amplitude/experiment-ios-client/commit/b11ba5e3669b6b4e30b5fbb1b72a20b9c4198f1e))
* uncomment save ([3c0833e](https://github.com/amplitude/experiment-ios-client/commit/3c0833efef4d69a379fa69440e4ef135910cb71b))


### Features

* add public ctors to config and user ([fc4f9f9](https://github.com/amplitude/experiment-ios-client/commit/fc4f9f912ca9c873285994b5644637d47df49936))
* save storage in userdefalts ([b89c1b7](https://github.com/amplitude/experiment-ios-client/commit/b89c1b78e78d7039ecac183a48d92a163a316a9e))
