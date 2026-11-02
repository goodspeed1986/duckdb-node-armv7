# JSON is shipped in the DuckDB source tree.
duckdb_extension_load(json)

# Quack availability/source integration must be confirmed against DuckDB v2.0.0.
# If Quack is external for the exact revision being built, replace this with:
# duckdb_extension_load(quack SOURCE_DIR /absolute/path/to/duckdb-quack)
duckdb_extension_load(quack)
