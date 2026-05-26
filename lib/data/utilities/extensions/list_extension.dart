extension ListRearrangeExtension<T> on List<T?> {
  List<T> rearrangeList(List<int> index) {
    // Create a new list to hold the rearranged items
    List<T?> rearrangedList = List.filled(index.length, null, growable: true);

    // Iterate over the index list
    for (int i = 0; i < index.length; i++) {
      // Check if the index is within the valid range
      if (index[i] >= 0 && index[i] < length) {
        // Assign the item at the corresponding index to the rearranged list
        rearrangedList[i] = this[index[i]];
      }
    }

    // Clear the original list and add the rearranged items
    rearrangedList.removeWhere((item) => item == null);
    return List<T>.from(rearrangedList);
  }
}

