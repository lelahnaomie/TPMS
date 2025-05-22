from flask import Flask, request, jsonify
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

# MySQL database configuration
DB_CONFIG = {
    'host': 'your_mysql_host',
    'user': 'your_mysql_user',
    'password': 'your_mysql_password',
    'database': 'your_mysql_database'
}

def get_db_connection():
    """Establishes and returns a MySQL database connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting to MySQL: {err}")
        return None

# ... (login route remains here) ...

@app.route('/signup', methods=['POST'])
def signup():
    """Handles user signup requests and stores data in the database."""
    if not request.is_json:
        return jsonify({'message': 'Request must be JSON'}), 400

    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    username = data.get('username') # Assuming you want to handle username

    if not email or not password or not username:
        return jsonify({'message': 'Email, password, and username are required'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'message': 'Database connection failed'}), 500

    cursor = conn.cursor()

    # Check if the email already exists
    query_check_email = "SELECT id FROM users WHERE email = %s"
    cursor.execute(query_check_email, (email,))
    existing_user_email = cursor.fetchone()

    if existing_user_email:
        cursor.close()
        conn.close()
        return jsonify({'message': 'Email already registered'}), 409 # Conflict

    # Check if the username already exists (optional)
    query_check_username = "SELECT id FROM users WHERE username = %s"
    cursor.execute(query_check_username, (username,))
    existing_user_username = cursor.fetchone()

    if existing_user_username:
        cursor.close()
        conn.close()
        return jsonify({'message': 'Username already taken'}), 409 # Conflict

    # Hash the password securely before storing it
    hashed_password = generate_password_hash(password)

    try:
        query_insert = "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)"
        cursor.execute(query_insert, (username, email, hashed_password))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'Signup successful'}), 201 # Created
    except mysql.connector.Error as err:
        print(f"Error inserting data: {err}")
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({'message': 'Signup failed'}), 500

if __name__ == '__main__':
    app.run(debug=True)