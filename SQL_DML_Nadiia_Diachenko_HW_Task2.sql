
--Investigation results 


 --a) Space consumption of ‘table_to_delete’ table before and after each operation;
    --before operations - 575MB
    --after DELETE - 575MB
    --after TRUNCATE - 8192 bytes
    --after VACUUM FULL - 383 MB

-- b) Comparison of DELETE and TRUNCATE in terms of:

-- execution time:
-- DELETE: 30 s vs TRUNCATE: 1.257 s

-- disk space usage:
-- DELETE does not free disk space vs TRUNCATE clears the space 

-- transaction behavior:
-- both operations are transactional

-- rollback possibility:
-- both operations can be rolled back

--c) Explanation:

--why DELETE does not free space immediately
--DELETE does not free space because it does not removes rows (but data only) - the table does not shrink

--why VACUUM FULL changes table size
--it clears not only the row data but also the empty rows themselves, overwriting the table and eliminating the empty space

--why TRUNCATE behaves differently
--TRUNCATE reduces the space because it clears the data and related table structure

--how these operations affect performance and storage
-- TRUNCATE:
-- fast operation, works at the table level
-- releases storage space used by table rows

-- DELETE:
-- slower operation, works at the row level, requires processing each row individually
-- does not free space, only marks rows as deleted


               

               