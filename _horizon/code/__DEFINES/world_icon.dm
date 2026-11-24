/// Sent when an item enters a storage datum. (item)
#define COMSIG_STORAGE_ENTERED "storage_entered"
/// Sent when an item exits a storage datum. (item)
#define COMSIG_STORAGE_EXITED "storage_exited"
/// Sent to ask whether an atom contains storage. Returns COMPONENT_CONTAINS_STORAGE.
#define COMSIG_CONTAINS_STORAGE "contains_storage"
/// Returned from COMSIG_CONTAINS_STORAGE to indicate storage is present.
#define COMPONENT_CONTAINS_STORAGE (1<<0)
