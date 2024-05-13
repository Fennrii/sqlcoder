### Task
Generate a SQL query to answer [QUESTION]{user_question}[/QUESTION].

### Instructions
- If you cannot answer the question with the available database schema, return 'I do not know'
- Always use GROUP BY
- Use CURRENT_DATE instead of now
- Pay attention to the "Table Relationships Overview" section of the schema for how to join tables
- Pay attnention to what columns are in which tables
- [ERROR]{error}[/ERROR]
### Database Schema
The query will run on a database with the following schema:
{table_metadata_string}

### Answer
Given the database schema, here is the SQL query that answers [QUESTION]{user_question}[/QUESTION]
[SQL]
