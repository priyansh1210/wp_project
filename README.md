# The Archive Co. - Library Portal

A full-stack **Library Management System** built with Java Servlets, JSP, MySQL, and deployed on Apache Tomcat. Features separate dashboards for **Admins** and **Members** with complete book borrowing, user management, and branch management capabilities.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Pages Overview](#pages-overview)
  - [Authentication](#authentication)
  - [Admin Panel](#admin-panel)
  - [Member Panel](#member-panel)
- [Database Schema](#database-schema)
- [Servlets](#servlets)
- [Setup & Installation](#setup--installation)
  - [Prerequisites](#prerequisites)
  - [Step 1 - Clone the Repository](#step-1---clone-the-repository)
  - [Step 2 - Set Up MySQL](#step-2---set-up-mysql)
  - [Step 3 - Create the Database](#step-3---create-the-database)
  - [Step 4 - Configure Tomcat](#step-4---configure-tomcat)
  - [Step 5 - Deploy & Run](#step-5---deploy--run)
- [Default Credentials](#default-credentials)
- [Screenshots](#screenshots)

---

## Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Backend    | Java Servlets (Jakarta EE / Servlet 6.0) |
| Frontend   | JSP, HTML5, CSS3, Vanilla JavaScript |
| Database   | MySQL 8.4                           |
| Server     | Apache Tomcat 10.1                  |
| JDBC Driver| MySQL Connector/J                   |

---

## Project Structure

```
LibraryPortal/
├── WEB-INF/
│   ├── classes/com/library/servlets/   # Java Servlet classes
│   │   ├── DBConnection.java           # Database connection utility
│   │   ├── AdminLoginServlet.java      # Admin authentication
│   │   ├── MemberLoginServlet.java     # Member authentication
│   │   ├── AdminRegisterServlet.java   # Admin registration
│   │   ├── MemberRegisterServlet.java  # Member registration
│   │   ├── AddBookServlet.java         # Add new book
│   │   ├── UpdateBookServlet.java      # Edit book details
│   │   ├── DeleteBookServlet.java      # Remove book
│   │   ├── AddMemberServlet.java       # Admin adds member
│   │   ├── UpdateMemberServlet.java    # Edit member details
│   │   ├── DeleteMemberServlet.java    # Remove member
│   │   ├── AddBranchServlet.java       # Add library branch
│   │   ├── UpdateBranchServlet.java    # Edit branch details
│   │   ├── DeleteBranchServlet.java    # Remove branch
│   │   ├── BorrowBookServlet.java      # Member borrows a book
│   │   ├── ReturnBookServlet.java      # Member returns a book
│   │   ├── ChangeCredentialsServlet.java # Change password
│   │   ├── ForgotPasswordServlet.java  # Forgot password flow
│   │   ├── ResetPasswordServlet.java   # Reset password
│   │   └── LogoutServlet.java          # Session invalidation
│   ├── lib/
│   │   └── mysql-connector-j.jar       # MySQL JDBC driver
│   └── web.xml                         # Deployment descriptor
├── includes/
│   ├── adminSidebar.jsp                # Admin navigation sidebar
│   ├── adminTopbar.jsp                 # Admin top header bar
│   ├── memberSidebar.jsp               # Member navigation sidebar
│   └── memberTopbar.jsp                # Member top header bar
├── css/
│   └── style.css                       # Complete application styles
├── js/
│   └── main.js                         # Client-side interactivity
├── img/                                # SVG icons and logos
├── sql/
│   └── schema_update.sql               # Database migration script
├── login.jsp                           # Entry point - login page
├── register.jsp                        # User registration
├── forgotPassword.jsp                  # Password recovery
├── resetPassword.jsp                   # Password reset form
├── adminDashboard.jsp                  # Admin main dashboard
├── adminBooks.jsp                      # Admin book management
├── adminUsers.jsp                      # Admin user management
├── adminBranches.jsp                   # Admin branch management
├── adminCatalog.jsp                    # Admin borrow/return tracking
├── memberDashboard.jsp                 # Member main dashboard
├── memberBooks.jsp                     # Member book browsing
├── memberBorrows.jsp                   # Member borrow history
└── memberProfile.jsp                   # Member profile page
```

---

## Pages Overview

### Authentication

| Page                 | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `login.jsp`          | Split-screen login with role toggle (Admin / Member). Entry point. |
| `register.jsp`       | Registration form for both Admin and Member accounts.              |
| `forgotPassword.jsp` | Username-based password recovery initiation.                       |
| `resetPassword.jsp`  | Enter new password after username verification.                    |

### Admin Panel

| Page                   | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `adminDashboard.jsp`   | Overview with stats (total users, books, branches), donut chart for borrow status, overdue borrowers list, and recent activity. |
| `adminBooks.jsp`       | Full CRUD for books - add, view, edit, delete. Searchable table with columns: ID, Title, Genre, Language, Quantity, Available. |
| `adminUsers.jsp`       | Full CRUD for members - add, view, edit, delete. Searchable table with columns: ID, Name, Email, Username. |
| `adminBranches.jsp`    | Full CRUD for library branches - add, view, edit, delete. Searchable table with columns: ID, Name, Contact, Location. |
| `adminCatalog.jsp`     | Tracks all borrow/return activity. View borrowed books, overdue items, and process returns. Tab-based interface. |

### Member Panel

| Page                   | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `memberDashboard.jsp`  | Personal overview with stats (total books, available, currently borrowed, total borrows) and recent activity table. |
| `memberBooks.jsp`      | Browse all library books in a card layout. Filter by genre, search by title. Borrow books directly from the card. |
| `memberBorrows.jsp`    | View currently borrowed books and full borrowing history. Return books from the "Currently Borrowed" tab. |
| `memberProfile.jsp`    | View personal details (ID, name, email, username, join date). Change password. |

### Shared Components

| Component              | Description                                              |
|------------------------|----------------------------------------------------------|
| `includes/adminSidebar.jsp`  | Admin navigation: Dashboard, Catalog, Books, Users, Branches, Logout. |
| `includes/memberSidebar.jsp` | Member navigation: Dashboard, Browse Books, My Borrows, Profile, Logout. |
| `includes/adminTopbar.jsp`   | Admin header with name, role, live clock, and settings.  |
| `includes/memberTopbar.jsp`  | Member header with name, role, live clock, and settings. |

---

## Database Schema

**Database name:** `library_portal`

### Tables

#### `admin`
| Column        | Type          | Description            |
|---------------|---------------|------------------------|
| id            | INT (PK, AI)  | Admin ID               |
| name          | VARCHAR(100)  | Full name              |
| first_name    | VARCHAR(50)   | First name             |
| last_name     | VARCHAR(50)   | Last name              |
| username      | VARCHAR(50)   | Unique username        |
| email         | VARCHAR(100)  | Email address          |
| password      | VARCHAR(255)  | Password               |
| contact_no    | VARCHAR(20)   | Contact number         |
| created_at    | TIMESTAMP     | Account creation date  |

#### `members`
| Column        | Type          | Description            |
|---------------|---------------|------------------------|
| id            | INT (PK, AI)  | Member ID              |
| name          | VARCHAR(100)  | Full name              |
| username      | VARCHAR(50)   | Unique username        |
| email         | VARCHAR(100)  | Email address          |
| password      | VARCHAR(255)  | Password               |
| contact_no    | VARCHAR(20)   | Contact number         |
| created_at    | TIMESTAMP     | Account creation date  |

#### `books`
| Column        | Type          | Description                   |
|---------------|---------------|-------------------------------|
| id            | INT (PK, AI)  | Book ID                       |
| title         | VARCHAR(200)  | Book title                    |
| author        | VARCHAR(100)  | Author name                   |
| isbn          | VARCHAR(20)   | ISBN number                   |
| genre         | VARCHAR(50)   | Genre/category                |
| language      | VARCHAR(50)   | Language (default: English)   |
| quantity      | INT           | Total copies                  |
| available     | INT           | Currently available copies    |
| added_by      | INT           | Admin who added the book      |
| created_at    | TIMESTAMP     | Date added                    |

#### `branches`
| Column        | Type          | Description            |
|---------------|---------------|------------------------|
| id            | INT (PK, AI)  | Branch ID              |
| name          | VARCHAR(100)  | Branch name            |
| contact_no    | VARCHAR(20)   | Contact number         |
| location      | VARCHAR(200)  | Branch location        |
| added_by      | INT           | Admin who added it     |
| created_at    | TIMESTAMP     | Date added             |

#### `borrow_history`
| Column        | Type          | Description                        |
|---------------|---------------|------------------------------------|
| id            | INT (PK, AI)  | Record ID                          |
| member_id     | INT (FK)      | References `members.id`            |
| book_id       | INT (FK)      | References `books.id`              |
| borrow_date   | TIMESTAMP     | When the book was borrowed         |
| return_date   | TIMESTAMP     | When the book was returned (nullable) |
| status        | VARCHAR(20)   | `BORROWED` or `RETURNED`           |

---

## Servlets

All servlets are in `com.library.servlets` package and use `@WebServlet` annotations for URL mapping.

| Servlet                    | URL Pattern              | Method | Description                       |
|----------------------------|--------------------------|--------|-----------------------------------|
| AdminLoginServlet          | /AdminLoginServlet       | POST   | Authenticates admin credentials   |
| MemberLoginServlet         | /MemberLoginServlet      | POST   | Authenticates member credentials  |
| AdminRegisterServlet       | /AdminRegisterServlet    | POST   | Creates new admin account         |
| MemberRegisterServlet      | /MemberRegisterServlet   | POST   | Creates new member account        |
| LogoutServlet              | /LogoutServlet           | GET    | Invalidates session, redirects to login |
| AddBookServlet             | /AddBookServlet          | POST   | Adds a new book to catalog        |
| UpdateBookServlet          | /UpdateBookServlet       | POST   | Updates book details              |
| DeleteBookServlet          | /DeleteBookServlet       | GET    | Deletes a book by ID              |
| AddMemberServlet           | /AddMemberServlet        | POST   | Admin creates a member account    |
| UpdateMemberServlet        | /UpdateMemberServlet     | POST   | Admin updates member details      |
| DeleteMemberServlet        | /DeleteMemberServlet     | GET    | Admin deletes a member            |
| AddBranchServlet           | /AddBranchServlet        | POST   | Adds a new library branch         |
| UpdateBranchServlet        | /UpdateBranchServlet     | POST   | Updates branch details            |
| DeleteBranchServlet        | /DeleteBranchServlet     | GET    | Deletes a branch by ID            |
| BorrowBookServlet          | /BorrowBookServlet       | POST   | Records a book borrow             |
| ReturnBookServlet          | /ReturnBookServlet       | POST   | Records a book return             |
| ChangeCredentialsServlet   | /ChangeCredentialsServlet| POST   | Changes user password             |
| ForgotPasswordServlet      | /ForgotPasswordServlet   | POST   | Initiates password reset          |
| ResetPasswordServlet       | /ResetPasswordServlet    | POST   | Completes password reset          |

---

## Setup & Installation

### Prerequisites

- **Java JDK 21** or higher
- **Apache Tomcat 10.1** or higher
- **MySQL 8.0** or higher

> The `tools/` directory in this repo already includes portable versions of JDK 21, Tomcat 10.1.52, and MySQL 8.4.4 for Windows. You can use these directly or install your own.

### Step 1 - Clone the Repository

```bash
git clone https://github.com/priyansh1210/wp_project.git
cd wp_project
```

### Step 2 - Set Up MySQL

**Option A: Use the bundled MySQL (Windows)**

```bash
# Initialize MySQL data directory (first time only)
./tools/mysql-8.4.4-winx64/bin/mysqld --initialize-insecure --basedir=./tools/mysql-8.4.4-winx64 --datadir=./tools/mysql-8.4.4-winx64/data

# Start MySQL server
./tools/mysql-8.4.4-winx64/bin/mysqld --console --basedir=./tools/mysql-8.4.4-winx64 --datadir=./tools/mysql-8.4.4-winx64/data
```

**Option B: Use your own MySQL installation**

Make sure MySQL is running on `localhost:3306` with user `root` and no password. If your setup differs, update the connection details in:

```
LibraryPortal/WEB-INF/classes/com/library/servlets/DBConnection.java
```

```java
private static final String URL = "jdbc:mysql://localhost:3306/library_portal";
private static final String USER = "root";
private static final String PASSWORD = "";
```

After modifying, recompile:

```bash
javac -cp "path/to/mysql-connector-j.jar;path/to/tomcat/lib/servlet-api.jar" DBConnection.java
```

### Step 3 - Create the Database

Connect to MySQL and run:

```sql
CREATE DATABASE IF NOT EXISTS library_portal;
USE library_portal;

-- Admin table
CREATE TABLE IF NOT EXISTS admin (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  username VARCHAR(50) UNIQUE,
  email VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  contact_no VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Members table
CREATE TABLE IF NOT EXISTS members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  username VARCHAR(50) UNIQUE,
  email VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  contact_no VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Books table
CREATE TABLE IF NOT EXISTS books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  author VARCHAR(100),
  isbn VARCHAR(20),
  genre VARCHAR(50),
  language VARCHAR(50) DEFAULT 'English',
  quantity INT DEFAULT 1,
  available INT DEFAULT 1,
  added_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Branches table
CREATE TABLE IF NOT EXISTS branches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  contact_no VARCHAR(20),
  location VARCHAR(200),
  added_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Borrow History table
CREATE TABLE IF NOT EXISTS borrow_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  book_id INT NOT NULL,
  borrow_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  return_date TIMESTAMP NULL,
  status VARCHAR(20) DEFAULT 'BORROWED',
  FOREIGN KEY (member_id) REFERENCES members(id),
  FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Insert a default branch
INSERT INTO branches (name, contact_no, location) VALUES
('The Archive Co. - Main', '0412410984', 'Bengaluru');
```

### Step 4 - Configure Tomcat

**Option A: Use the bundled Tomcat**

The app is already deployed at `tools/apache-tomcat-10.1.52/webapps/LibraryPortal/`.

**Option B: Use your own Tomcat**

Copy the `LibraryPortal/` folder into your Tomcat's `webapps/` directory:

```bash
cp -r LibraryPortal /path/to/tomcat/webapps/
```

Make sure `mysql-connector-j.jar` is present in either:
- `LibraryPortal/WEB-INF/lib/` (already included), OR
- `tomcat/lib/` (global)

### Step 5 - Deploy & Run

```bash
# Set JAVA_HOME (adjust path to your JDK)
export JAVA_HOME="./tools/jdk-21.0.10+7"

# Start Tomcat
./tools/apache-tomcat-10.1.52/bin/startup.sh    # Linux/Mac
./tools/apache-tomcat-10.1.52/bin/startup.bat    # Windows
```

Open your browser and navigate to:

```
http://localhost:8080/LibraryPortal
```

You will be redirected to the login page. Register a new Admin or Member account to get started.

---

## Default Credentials

No default accounts are created. Register your first admin account via the registration page:

1. Go to `http://localhost:8080/LibraryPortal/register.jsp`
2. Select **Admin** role
3. Fill in the form and register
4. Log in with your new credentials

---

## Key Features

- **Role-based access** - Separate Admin and Member interfaces
- **Book management** - Full CRUD with genre, language, and availability tracking
- **Borrow/Return system** - Members borrow books, admins track overdue items
- **Branch management** - Manage multiple library branches
- **User management** - Admins can add, edit, and remove member accounts
- **Dashboard analytics** - Visual stats with donut charts and activity feeds
- **Responsive design** - Clean black & white theme with CSS variables
- **Live clock** - Real-time clock display in the topbar
- **Search & filter** - Real-time table search and genre-based book filtering
- **Session management** - 30-minute timeout with role-based access control
- **Password recovery** - Forgot password and reset flow

---

## License

This project was built as a Web Programming Lab project at MIT Bengaluru.
