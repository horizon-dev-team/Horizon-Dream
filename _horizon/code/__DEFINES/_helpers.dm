/// Type is abstract and should be skipped in type iterations, etc.
#define IS_ABSTRACT(datum_type) (initial(datum_type.abstract_type) == datum_type)
