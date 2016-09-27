2.2.1
---
* Backport Fix clash with rspec-rails

2.2.0
---
* Fix typo in README file [bradhaydon#87]
* Fix type in readme [graudeejs#80]
* Matchers::HaveEnqueuedJob breaks on jobs with Hash arguments [erikogan#77]
* have_enqueued_job fails if args includes a Hash bug [gPrado#74]

2.1.0
---
* ActiveJob support [tarzan#71]
* adding be expired in matcher [bernabas#72]
* Fixed testing failures with be_delayed matcher due to rename of `enqueued_at` to `created_at` in latest Sidekiq [philostler]
* Add support for NullBatch#on and NullStatus#failures to the null batch objects. [PacerPRO#64]
* Adding a save_backtrace matcher [webdestroya#61]
* Add flag to skip Batch stubs [paulfri#69]
* allow passing an instance method to be_delayed matcher [lastobelus#63]

2.0.0
---
* Get specs to green [petergoldstein#58]
* Update spec syntax in README. [futhr#60]

2.0.0.beta
---
* Add support for 3.0.0 [yelled3#47]
* Completely remove have_enqueued_jobs matcher [philostler#56]

1.1.0
---
* Added Support for RSpec 3 [TBAA#44]
* Fix gem build error ERROR: (Gem::InvalidSpecificationException) [mourad-ifeelgoods#42]
* Make sure sidekiq is required [mourad-ifeelgoods#43]
* attempt at fixing 'undefined method `configure' for RSpec:Module' [homanchou#51]
* Supports accessing the batch id [fabiokr#54]
* Pass message hash to retries_exhausted block [layervault#52]
* added support for unique scheduled worker matching [jkogara#55]

1.0.0
---
* Improve coverage and readability of README [philostler#26]
* Greatly increase test coverage [philostler#27]
* Refactor and greatly improve be_a_delayed_job matcher (now be_delayed) [philostler#24 & #25]
* Add implementation of status.total [matthargett & Kelly Felkins#32 & #39]
* Fix Rubinius build [petergoldstein#38]
* Remove have_enqueued_jobs matcher [philostler#37]
* Travis - Ruby 2.1.0, fix Rubinius build [petergoldstein#35]
* Prepare for RSpec 3.x [petergoldstein#34]
* Print warning when used in development mode [mperham & philostler#33]
* Add helper for testing retries exhausted block [Noreaster76#31]
* Allow to use [general matchers](https://www.relishapp.com/rspec/rspec-mocks/v/2-14/docs/argument-matchers/general-matchers) in have_enqueued_job [johanneswuerbach#30]
* Loosen RSpec dependency [philostler#23]
* Add delay extension matchers [sosaucily#22]
* Update coveralls development dependency to version 0.7.x [philostler]

0.5.1
---
* Allows Sidekiq::Batch support to work with Mocha as well RSpec stubbing [noiseunion#20]

0.5.0
---
* Adds stub support for Sidekiq::Batch [kmayer#17]

0.4.0
---
* Bug fix for matcher failure if sidekiq_options were defined as strings vs symbols [mhuffnagle#16 & philostler]
* Matcher tests (partial coverage) added [mhuffnagle#16 & philostler]

0.3.0
---
* Removed restriction on needing to use sidekiq-middleware with be_unique matcher [philostler#4]
* Ensure RSpec.configure is defined on loading rspec/sidekiq/matchers [centaure#3]

0.2.2
---
* Matcher ```be_retryable false``` not producing correct output description [philostler]

0.2.1
---
* Removed debug #puts [philostler]

0.2.0
---
* New #have_enqueued_job matcher [philostler]
* Improved #have_enqueued_jobs description [philostler]
* Minor documentation updates [philostler]

0.1.0
---
* Initial release [philostler]
