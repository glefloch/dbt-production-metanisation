.PHONY:  all

# Clean target foler, run models, and test them
all: clean run test

# Clean the target folder
clean: 
	dbt clean

run:
	dbt run

# Run dbt test
test:
	dbt test

# execute sqlfluff to format sql models
lint: 
	sqlfluff fix -f --dialect bigquery models/
 