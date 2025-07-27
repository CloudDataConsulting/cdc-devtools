"""Example: Working with multiple database connections."""

import logging
from pathlib import Path
import sys
from typing import Dict, Any

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent.parent.parent))

from secrets_management import CDCSecretsManager

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def snowflake_example():
    """Demonstrate Snowflake connection with secrets management."""
    try:
        import snowflake.connector
    except ImportError:
        logger.warning("snowflake-connector-python not installed. Skipping example.")
        return
    
    secrets = CDCSecretsManager()
    
    # Get Snowflake credentials
    logger.info("Retrieving Snowflake credentials from 1Password...")
    snowflake_config = secrets.get_database_config('snowflake_prod')
    
    # Connect to Snowflake
    logger.info("Connecting to Snowflake...")
    conn = snowflake.connector.connect(
        account=snowflake_config['account'],
        user=snowflake_config['username'],
        password=snowflake_config['password'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        role=snowflake_config['role']
    )
    
    try:
        # Run a simple query
        cursor = conn.cursor()
        cursor.execute("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE()")
        result = cursor.fetchone()
        
        print("\n=== Snowflake Connection Info ===")
        print(f"User: {result[0]}")
        print(f"Role: {result[1]}")
        print(f"Warehouse: {result[2]}")
        
        # Example: List databases
        cursor.execute("SHOW DATABASES")
        databases = cursor.fetchall()
        
        print("\nAccessible Databases:")
        for db in databases[:5]:  # Show first 5
            print(f"  - {db[1]}")  # Database name is typically in column 1
            
    finally:
        conn.close()
        logger.info("Snowflake connection closed")


def postgres_example():
    """Demonstrate PostgreSQL connection with secrets management."""
    try:
        import psycopg2
    except ImportError:
        logger.warning("psycopg2 not installed. Skipping example.")
        return
    
    secrets = CDCSecretsManager()
    
    # Get PostgreSQL credentials
    logger.info("Retrieving PostgreSQL credentials from 1Password...")
    pg_config = secrets.get_database_config('postgres_analytics')
    
    # Connect to PostgreSQL
    logger.info("Connecting to PostgreSQL...")
    conn = psycopg2.connect(
        host=pg_config['host'],
        port=pg_config.get('port', 5432),
        database=pg_config['database'],
        user=pg_config['username'],
        password=pg_config['password']
    )
    
    try:
        cursor = conn.cursor()
        
        # Get connection info
        cursor.execute("SELECT current_user, current_database(), version()")
        result = cursor.fetchone()
        
        print("\n=== PostgreSQL Connection Info ===")
        print(f"User: {result[0]}")
        print(f"Database: {result[1]}")
        print(f"Version: {result[2][:50]}...")  # First 50 chars of version
        
        # Example: List tables
        cursor.execute("""
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
            LIMIT 10
        """)
        
        tables = cursor.fetchall()
        if tables:
            print("\nSample Tables:")
            for schema, table in tables:
                print(f"  - {schema}.{table}")
                
    finally:
        conn.close()
        logger.info("PostgreSQL connection closed")


def multi_database_etl_example():
    """Demonstrate ETL between multiple databases."""
    
    secrets = CDCSecretsManager()
    
    print("\n=== Multi-Database ETL Example ===")
    print("Scenario: Copy data from PostgreSQL to Snowflake")
    
    # This is a conceptual example showing how you'd structure multi-DB operations
    
    # Step 1: Get credentials for both databases
    pg_config = secrets.get_database_config('postgres_analytics')
    sf_config = secrets.get_database_config('snowflake_prod')
    
    print("\n1. Retrieved credentials for both databases")
    print(f"   - PostgreSQL: {pg_config.get('host', 'localhost')}:{pg_config.get('port', 5432)}")
    print(f"   - Snowflake: {sf_config.get('account', 'account')}.snowflakecomputing.com")
    
    # Step 2: In real ETL, you would:
    print("\n2. ETL Process (simulated):")
    print("   - Connect to PostgreSQL source")
    print("   - Execute extraction query")
    print("   - Transform data as needed")
    print("   - Connect to Snowflake target")
    print("   - Load data using COPY or INSERT")
    print("   - Verify row counts match")
    
    # Example of how credentials would be used
    etl_code_example = """
    # Extraction
    pg_conn = psycopg2.connect(**pg_config)
    pg_cursor = pg_conn.cursor()
    pg_cursor.execute("SELECT * FROM analytics.user_events WHERE date >= '2024-01-01'")
    
    # Loading
    sf_conn = snowflake.connector.connect(**sf_config)
    sf_cursor = sf_conn.cursor()
    sf_cursor.execute("CREATE TEMP TABLE staging_user_events (...)")
    sf_cursor.executemany("INSERT INTO staging_user_events VALUES (%s, %s, ...)", data)
    """
    
    print("\n3. Example code structure:")
    print(etl_code_example)


def connection_pool_example():
    """Demonstrate connection pooling with secrets management."""
    
    from functools import lru_cache
    
    class DatabaseConnectionManager:
        """Manage database connections with pooling."""
        
        def __init__(self):
            self.secrets = CDCSecretsManager()
            self._connections = {}
        
        @lru_cache(maxsize=10)
        def get_connection_config(self, db_name: str) -> Dict[str, Any]:
            """Cache database configurations."""
            return self.secrets.get_database_config(db_name)
        
        def get_connection(self, db_name: str):
            """Get or create a database connection."""
            if db_name not in self._connections:
                config = self.get_connection_config(db_name)
                
                # Create connection based on database type
                if 'snowflake' in db_name:
                    # Would create Snowflake connection
                    logger.info(f"Creating Snowflake connection for {db_name}")
                elif 'postgres' in db_name:
                    # Would create PostgreSQL connection
                    logger.info(f"Creating PostgreSQL connection for {db_name}")
                
                # Store in connection pool
                self._connections[db_name] = f"MockConnection({db_name})"
            
            return self._connections[db_name]
        
        def close_all(self):
            """Close all connections."""
            for db_name, conn in self._connections.items():
                logger.info(f"Closing connection: {db_name}")
            self._connections.clear()
    
    print("\n=== Connection Pool Example ===")
    
    # Initialize manager
    manager = DatabaseConnectionManager()
    
    # Get connections (would be reused)
    conn1 = manager.get_connection('snowflake_prod')
    conn2 = manager.get_connection('postgres_analytics')
    conn3 = manager.get_connection('snowflake_prod')  # Reuses existing
    
    print(f"Connection 1: {conn1}")
    print(f"Connection 2: {conn2}")
    print(f"Connection 3: {conn3} (reused)")
    
    # Clean up
    manager.close_all()


if __name__ == "__main__":
    print("CDC Database Connections Example")
    print("=" * 50)
    
    # Check if config exists
    if not Path("config.yaml").exists():
        print("\nERROR: config.yaml not found!")
        print("Copy templates/config.yaml.example to config.yaml and configure your secrets.")
        sys.exit(1)
    
    try:
        # Run examples (some may skip if libraries not installed)
        snowflake_example()
        postgres_example()
        multi_database_etl_example()
        connection_pool_example()
        
        print("\n✅ Database examples completed!")
        print("\nKey Benefits Demonstrated:")
        print("- Centralized credential management")
        print("- Multiple database connections without conflicts")
        print("- Easy ETL between different databases")
        print("- Connection pooling with secure credentials")
        
    except Exception as e:
        logger.error(f"Example failed: {e}")
        print("\nTroubleshooting:")
        print("1. Check config.yaml has database configurations")
        print("2. Ensure 1Password CLI is authenticated")
        print("3. Install database drivers: pip install snowflake-connector-python psycopg2")