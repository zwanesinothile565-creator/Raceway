
/*
===========================================================
PROG6212 - Part 2
RACEWAY EVENT MANAGEMENT SYSTEM
DATABASE: RacewayDB
===========================================================
TABLES:
1. Organizer
2. Venue
3. Event
4. Category
5. Participant
6. Enrolment
7. tblRoles
8. tblUsers

RELATIONSHIPS:
Organizer 1:M Event
Venue 1:M Event
Event 1:M Category
Participant 1:M Enrolment
Category 1:M Enrolment
tblRoles 1:1 tblUsers
===========================================================
*/

IF DB_ID('RacewayDB') IS NULL
BEGIN
    CREATE DATABASE RacewayDB;
END
GO

USE RacewayDB;
GO

/* 1. ORGANIZER */

CREATE TABLE Organizer
(
    OrganizerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL
);
GO

/* 2. VENUE */

CREATE TABLE Venue
(
    VenueID INT IDENTITY(1,1) PRIMARY KEY,
    VenueName VARCHAR(150) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    City VARCHAR(100) NOT NULL
);
GO

/* 3. PARTICIPANT */

CREATE TABLE Participant
(
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Phone VARCHAR(20) NOT NULL
);
GO

/* 4. ROLES */

CREATE TABLE tblRoles
(
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(200) NULL
);
GO

/* 5. USERS
   UNIQUE RoleID enforces the requested 1:1 relationship.
*/

CREATE TABLE tblUsers
(
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(150) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RoleID INT NOT NULL UNIQUE,
    IsActive BIT NOT NULL DEFAULT (1),

    CONSTRAINT FK_tblUsers_tblRoles
        FOREIGN KEY (RoleID)
        REFERENCES tblRoles(RoleID)
);
GO

/* 6. EVENT */

CREATE TABLE [Event]
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganizerID INT NOT NULL,
    VenueID INT NOT NULL,
    EventName VARCHAR(150) NOT NULL,
    EventDate DATE NOT NULL,
    EventStatus VARCHAR(30) NOT NULL
        DEFAULT ('Scheduled'),

    CONSTRAINT FK_Event_Organizer
        FOREIGN KEY (OrganizerID)
        REFERENCES Organizer(OrganizerID),

    CONSTRAINT FK_Event_Venue
        FOREIGN KEY (VenueID)
        REFERENCES Venue(VenueID)
);
GO

/* 7. CATEGORY */

CREATE TABLE Category
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    DistanceKM DECIMAL(5,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Category_Event
        FOREIGN KEY (EventID)
        REFERENCES [Event](EventID),

    CONSTRAINT UQ_Category_Event_Name
        UNIQUE (EventID, CategoryName),

    CONSTRAINT CK_Category_Distance
        CHECK (DistanceKM > 0),

    CONSTRAINT CK_Category_EntryFee
        CHECK (EntryFee >= 0)
);
GO

/* 8. ENROLMENT */

CREATE TABLE Enrolment
(
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATE NOT NULL
        DEFAULT (CONVERT(DATE, GETDATE())),
    PaymentStatus VARCHAR(30) NOT NULL
        DEFAULT ('Pending'),
    RaceNumber INT NOT NULL UNIQUE,

    CONSTRAINT FK_Enrolment_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Participant(ParticipantID),

    CONSTRAINT FK_Enrolment_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID),

    CONSTRAINT CK_Enrolment_PaymentStatus
        CHECK (PaymentStatus IN
        ('Pending', 'Paid', 'Failed', 'Refunded'))
);
GO

/* INSERT 2 ORGANIZERS */

INSERT INTO Organizer (Name, Email, Phone)
VALUES
('Raceway Events', 'info@raceway.co.za', '0315551001'),
('KwaZulu Sports Events', 'events@raceway.co.za', '0315551002');
GO

/* INSERT 3 VENUES */

INSERT INTO Venue (VenueName, Address, City)
VALUES
('Moses Mabhida Stadium',
 '44 Isaiah Ntshangase Road', 'Durban'),
('Kings Park Athletics Stadium',
 'Jacko Jackson Drive', 'Durban'),
('Umhlanga Sports Centre',
 'Main Road', 'Umhlanga');
GO

/* INSERT 2 PARTICIPANTS */

INSERT INTO Participant
    (FirstName, LastName, Email, Phone)
VALUES
('Thabo', 'Mthembu',
 'thabo.mthembu@email.com', '0821112233'),
('Lerato', 'Khumalo',
 'lerato.khumalo@email.com', '0832223344');
GO

/* INSERT 2 ROLES */

INSERT INTO tblRoles (RoleName, Description)
VALUES
('Administrator', 'Manages users and system settings'),
('EventCoordinator', 'Manages events and enrolments');
GO

/* INSERT 2 USERS
   Demonstration password values only.
   Replace with securely generated password hashes
   before using the system in a real application.
*/

INSERT INTO tblUsers
    (Username, Email, PasswordHash, RoleID)
VALUES
('admin01', 'admin@raceway.co.za',
 'DEMO_HASH_REPLACE_WITH_REAL_HASH_01', 1),
('coordinator01', 'coordinator@raceway.co.za',
 'DEMO_HASH_REPLACE_WITH_REAL_HASH_02', 2);
GO

/* INSERT 3 EVENTS */

INSERT INTO [Event]
    (OrganizerID, VenueID, EventName, EventDate, EventStatus)
VALUES
(1, 1, 'Durban City Marathon',
 '2026-11-15', 'Scheduled'),
(1, 2, 'Kings Park Fun Run',
 '2026-11-22', 'Scheduled'),
(2, 3, 'Umhlanga Coastal Race',
 '2026-12-06', 'Scheduled');
GO

/* INSERT 8 CATEGORIES */

INSERT INTO Category
    (EventID, CategoryName, DistanceKM, EntryFee)
VALUES
(1, 'Marathon', 42.20, 350.00),
(1, 'Half Marathon', 21.10, 250.00),
(1, '10KM Run', 10.00, 150.00),
(2, '10KM Run', 10.00, 120.00),
(2, '5KM Fun Run', 5.00, 80.00),
(3, '21KM Coastal Race', 21.10, 220.00),
(3, '10KM Coastal Run', 10.00, 140.00),
(3, '5KM Fun Run', 5.00, 80.00);
GO

/* INSERT 4 ENROLMENTS */

INSERT INTO Enrolment
    (ParticipantID, CategoryID, EnrolmentDate,
     PaymentStatus, RaceNumber)
VALUES
(1, 1, '2026-10-01', 'Paid', 1001),
(2, 2, '2026-10-02', 'Paid', 1002),
(1, 4, '2026-10-03', 'Pending', 1003),
(2, 5, '2026-10-04', 'Paid', 1004);
GO

/* VERIFY ALL TABLES */

SELECT * FROM Organizer;
SELECT * FROM Venue;
SELECT * FROM [Event];
SELECT * FROM Category;
SELECT * FROM Participant;
SELECT * FROM Enrolment;
SELECT * FROM tblRoles;
SELECT * FROM tblUsers;
GO

/* VERIFY USER-ROLE RELATIONSHIP */

SELECT
    u.UserID,
    u.Username,
    u.Email AS UserEmail,
    r.RoleID,
    r.RoleName
FROM tblUsers AS u
INNER JOIN tblRoles AS r
    ON u.RoleID = r.RoleID;
GO
