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
