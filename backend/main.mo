import Bool "mo:base/Bool";
import Hash "mo:base/Hash";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Text "mo:base/Text";

actor {
  // Define the structure for a shopping list item
  type Item = {
    id: Nat;
    name: Text;
    completed: Bool;
  };

  // Stable variable to store items
  stable var itemEntries : [(Nat, Item)] = [];

  // Create a HashMap to store items
  var items = HashMap.HashMap<Nat, Item>(0, Nat.equal, Nat.hash);

  // Counter for generating unique IDs
  stable var nextId : Nat = 0;

  // Initialize the HashMap with stable data
  system func preupgrade() {
    itemEntries := Iter.toArray(items.entries());
  };

  system func postupgrade() {
    items := HashMap.fromIter<Nat, Item>(itemEntries.vals(), 0, Nat.equal, Nat.hash);
  };

  // Add a new item to the list
  public func addItem(name : Text) : async Nat {
    let id = nextId;
    nextId += 1;
    let newItem : Item = {
      id = id;
      name = name;
      completed = false;
    };
    items.put(id, newItem);
    id
  };

  // Get all items
  public query func getItems() : async [Item] {
    Iter.toArray(items.vals())
  };

  // Update item status (completed or not)
  public func updateItemStatus(id : Nat, completed : Bool) : async Bool {
    switch (items.get(id)) {
      case (null) { false };
      case (?item) {
        let updatedItem : Item = {
          id = item.id;
          name = item.name;
          completed = completed;
        };
        items.put(id, updatedItem);
        true
      };
    };
  };

  // Delete an item
  public func deleteItem(id : Nat) : async Bool {
    switch (items.remove(id)) {
      case (null) { false };
      case (?_) { true };
    };
  };
}
