// Mocks generated by Mockito 5.4.5 from annotations
// in sae_mobile/test/mock.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:sae_mobile/models/database/i_database.dart' as _i3;
import 'package:sae_mobile/models/restaurant.dart' as _i2;
import 'package:sae_mobile/models/review.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeRestaurant_0 extends _i1.SmartFake implements _i2.Restaurant {
  _FakeRestaurant_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [IDatabase].
///
/// See the documentation for Mockito's code generation for more information.
class MockIDatabase extends _i1.Mock implements _i3.IDatabase {
  MockIDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<List<_i2.Restaurant>> getRestaurants() =>
      (super.noSuchMethod(
            Invocation.method(#getRestaurants, []),
            returnValue: _i4.Future<List<_i2.Restaurant>>.value(
              <_i2.Restaurant>[],
            ),
          )
          as _i4.Future<List<_i2.Restaurant>>);

  @override
  _i4.Future<List<_i5.Review>> getReviews(String id) =>
      (super.noSuchMethod(
            Invocation.method(#getReviews, [id]),
            returnValue: _i4.Future<List<_i5.Review>>.value(<_i5.Review>[]),
          )
          as _i4.Future<List<_i5.Review>>);

  @override
  _i4.Future<void> deleteReview(int? id) =>
      (super.noSuchMethod(
            Invocation.method(#deleteReview, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<_i2.Restaurant> getRestaurantById(int? id) =>
      (super.noSuchMethod(
            Invocation.method(#getRestaurantById, [id]),
            returnValue: _i4.Future<_i2.Restaurant>.value(
              _FakeRestaurant_0(
                this,
                Invocation.method(#getRestaurantById, [id]),
              ),
            ),
          )
          as _i4.Future<_i2.Restaurant>);

  @override
  bool isConnected() =>
      (super.noSuchMethod(
            Invocation.method(#isConnected, []),
            returnValue: false,
          )
          as bool);
  @override
  _i4.Future<String> imageLink(String? restaurantName) =>
      (super.noSuchMethod(
        Invocation.method(#imageLink, [restaurantName]),
        returnValue: _i4.Future<String>.value('https://example.com/default.png'),
      ) as _i4.Future<String>);

}

