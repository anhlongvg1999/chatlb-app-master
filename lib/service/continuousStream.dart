import 'dart:collection';

class ContinuousStream {
  _DataStore _mStorage = _DataStore.getInstance();

  /// Sets a new value [value] to the data stream [stream].
  /// If there are active subscribers, the value will be dispatched to them.
  void emit(String stream, var value) {
    _mStorage?.setValue(stream, value);
  }

  /// Subscribes to the given stream [stream].
  /// If stream already has data set, it will be delivered to the [callback] function.
  void on(String stream, void Function(Object) callback) {
    _mStorage?.setCallback(stream, callback);
  }

  /// Returns the current value of a given data [stream].
  Object getValue(String stream) {
    return _mStorage?.getValue(stream);
  }
}

// Storage class for ContinuousStream.
class _DataStore {
  // Singleton Instance for DataStore
  static _DataStore _instance;

  // Map instance to store data values with data stream.
  HashMap<String, _DataItem> _mDataItemsMap = HashMap();

  // Sets/Adds the new value to the given key.
  void setValue(String key, var value) {
    // Retrieve existing data item from map.
    _DataItem item = _mDataItemsMap[key];

    item ??= _DataItem();

    // Set new value to new/existing item.
    item.value = value;

    // Reset item to the map.
    _mDataItemsMap[key] = item;

    // Dispatch new value to all callbacks.
    item.callbacks?.forEach((callback) {
      callback(value);
    });
  }

  // Sets/Adds the new callback to the given data stream.
  void setCallback(String key, Function(Object) callback) {
    if (callback != null) {
      // Retrieve existing data item from the map.
      _DataItem item = _mDataItemsMap[key];

      item ??= _DataItem();

      // Retrieve callback functions from data item.
      List<Function(Object)> callbacks = item.callbacks;

      // Check if callback functions exists or not.
      if (callbacks == null) {
        // If it's null then create new List.
        callbacks = List();

        // Set callback functions list to data item.
        item.callbacks = callbacks;

        // Set the data item to the map.
        _mDataItemsMap[key] = item;
      }

      // Add the given callback into List of callback functions.
      callbacks.add(callback);

      // Dispatch value to the callback function if value already exists.
      if (item.value != null) {
        callback(item.value);
      }
    }
  }

  // Returns current value of the data stream.
  Object getValue(String key) {
    return _mDataItemsMap[key].value;
  }

  // Returns singleton instance of _DataStore
  static _DataStore getInstance() {
    _instance ??= _DataStore();
    return _instance;
  }
}

// Data class to hold value and callback functions of a data stream.
class _DataItem {
  var value;
  List<Function(Object)> callbacks;
}
