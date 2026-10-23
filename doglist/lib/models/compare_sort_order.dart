import 'dog.dart';

enum CompareSortOrder {
  unsorted,
  alphabetical,
  likes,
  size;

  bool get defaultAscending => this != CompareSortOrder.likes;

  List<Dog> sortDogs(
    Iterable<Dog> dogs, {
    bool? ascending,
    Map<String, int> likeCounts = const {},
  }) {
    final sortedDogs = dogs.toList();
    if (this == CompareSortOrder.unsorted) return sortedDogs;

    final originalPositions = {
      for (var index = 0; index < sortedDogs.length; index++) sortedDogs[index].id: index,
    };
    final isAscending = ascending ?? defaultAscending;
    sortedDogs.sort((first, second) {
      final comparison = switch (this) {
        CompareSortOrder.unsorted => 0,
        CompareSortOrder.alphabetical => first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        CompareSortOrder.likes => (likeCounts[first.id] ?? 0).compareTo(likeCounts[second.id] ?? 0),
        CompareSortOrder.size => first.size.compareTo(second.size),
      };
      if (comparison == 0) return originalPositions[first.id]!.compareTo(originalPositions[second.id]!);
      return isAscending ? comparison : -comparison;
    });
    return sortedDogs;
  }
}