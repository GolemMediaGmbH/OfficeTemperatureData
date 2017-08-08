# OfficeTemperatureData
Raw data and processing code for analysis

## Recommended settings for MySQL

Requires at least 16 GByte RAM.

```
[mysqld]
general-log=0
innodb-buffer-pool-size=858993452
innodb-change-buffer-max-size=50
innodb-max-dirty-pages-pct=90
innodb-flush-log-at-trx-commit=0
max-heap-table-size=10737421824
secure_file_priv=
```