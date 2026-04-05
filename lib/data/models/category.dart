import 'package:flutter/material.dart';

enum Category {
  grocery,
  family,
  vegetables,
  friends,
  party,
  travel,
  movie,
  others;

  String get displayName {
    switch (this) {
      case Category.grocery:
        return 'Grocery';
      case Category.family:
        return 'Family';
      case Category.vegetables:
        return 'Vegetables';
      case Category.friends:
        return 'Friends';
      case Category.party:
        return 'Party';
      case Category.travel:
        return 'Travel';
      case Category.movie:
        return 'Movie';
      case Category.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.grocery:
        return Icons.local_grocery_store;
      case Category.family:
        return Icons.family_restroom;
      case Category.vegetables:
        return Icons.eco;
      case Category.friends:
        return Icons.people;
      case Category.party:
        return Icons.party_mode_rounded;
      case Category.travel:
        return Icons.flight_takeoff;
      case Category.movie:
        return Icons.movie;
      case Category.others:
        return Icons.category;
    }
  }
}
