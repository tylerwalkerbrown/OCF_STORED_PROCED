CALL master_clean ()

CALL master_table_creation()

CALL clean_refresh()

CALL inserting_data()

DROP TABLE `old_cobblers_farm`.`order_refresh`;
DROP TABLE `old_cobblers_farm`.`transactions`;
