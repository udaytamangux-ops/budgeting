import 'package:flutter/material.dart';

abstract final class CategoryIconData {
  static IconData forKey(String key) => switch (key) {
    'food' => Icons.restaurant_outlined,
    'transport' => Icons.directions_bus_outlined,
    'home' => Icons.home_outlined,
    'utilities' => Icons.bolt_outlined,
    'shopping' => Icons.shopping_bag_outlined,
    'health' => Icons.health_and_safety_outlined,
    'education' => Icons.school_outlined,
    'entertainment' => Icons.movie_outlined,
    'family' => Icons.people_outline,
    'receipt' => Icons.receipt_long_outlined,
    'work' => Icons.work_outline,
    'laptop' => Icons.laptop_outlined,
    'business' => Icons.storefront_outlined,
    'wallet' => Icons.account_balance_wallet_outlined,
    'globe' => Icons.public_outlined,
    'gift' => Icons.redeem_outlined,
    'refund' => Icons.replay_outlined,
    'fitness' => Icons.fitness_center_outlined,
    'travel' => Icons.flight_outlined,
    'pets' => Icons.pets_outlined,
    'savings' => Icons.savings_outlined,
    'subscriptions' => Icons.subscriptions_outlined,
    _ => Icons.label_outline,
  };
}
