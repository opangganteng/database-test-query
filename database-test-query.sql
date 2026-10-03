-- SIPERPUS - MySQL 8.0
-- Jalankan seluruh file ini pada database kosong.

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    ktp_number CHAR(16) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    publisher VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publication_year SMALLINT NOT NULL,
    available_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_books_available_quantity CHECK (available_quantity >= 0)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE
);

-- Relasi many-to-many: satu buku dapat memiliki beberapa kategori,
-- dan satu kategori dapat digunakan oleh banyak buku.
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_categories_category
        FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrowed_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE NULL,
    CONSTRAINT chk_loans_due_date CHECK (due_at >= borrowed_at),
    CONSTRAINT chk_loans_return_date CHECK (returned_at IS NULL OR returned_at >= borrowed_at),
    CONSTRAINT fk_loans_user
        FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loans_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Data awal: 5 kategori.
INSERT INTO categories (category_id, category_name) VALUES
    (1, 'Fiksi'),
    (2, 'Sains'),
    (3, 'Sejarah'),
    (4, 'Teknologi'),
    (5, 'Pendidikan');

-- Data awal: 5 anggota perpustakaan.
INSERT INTO users (user_id, name, address, ktp_number, phone_number, email) VALUES
    (1, 'User 1', 'Jl. Merdeka No. 1, Jakarta', '3171000000000001', '081200000001', 'user1@example.com'),
    (2, 'User 2', 'Jl. Sudirman No. 2, Jakarta', '3171000000000002', '081200000002', 'user2@example.com'),
    (3, 'User 3', 'Jl. Diponegoro No. 3, Bandung', '3273000000000003', '081200000003', 'user3@example.com'),
    (4, 'User 4', 'Jl. Asia Afrika No. 4, Bandung', '3273000000000004', '081200000004', 'user4@example.com'),
    (5, 'User 5', 'Jl. Malioboro No. 5, Yogyakarta', '3471000000000005', '081200000005', 'user5@example.com');

-- Data awal: 10 buku. Buku 10 belum pernah dipinjam.
INSERT INTO books (book_id, title, author, publisher, isbn, publication_year, available_quantity) VALUES
    (1, 'Buku 1', 'Pengarang 1', 'Penerbit A', '9780000000001', 2020, 1),
    (2, 'Buku 2', 'Pengarang 2', 'Penerbit A', '9780000000002', 2021, 1),
    (3, 'Buku 3', 'Pengarang 3', 'Penerbit B', '9780000000003', 2019, 1),
    (4, 'Buku 4', 'Pengarang 4', 'Penerbit B', '9780000000004', 2018, 1),
    (5, 'Buku 5', 'Pengarang 5', 'Penerbit C', '9780000000005', 2022, 1),
    (6, 'Buku 6', 'Pengarang 6', 'Penerbit C', '9780000000006', 2023, 1),
    (7, 'Buku 7', 'Pengarang 7', 'Penerbit D', '9780000000007', 2020, 1),
    (8, 'Buku 8', 'Pengarang 8', 'Penerbit D', '9780000000008', 2021, 1),
    (9, 'Buku 9', 'Pengarang 9', 'Penerbit E', '9780000000009', 2017, 1),
    (10, 'Buku 10', 'Pengarang 10', 'Penerbit E', '9780000000010', 2024, 2);

INSERT INTO book_categories (book_id, category_id) VALUES
    (1, 1), (2, 2), (3, 1), (4, 3), (5, 5),
    (6, 4), (7, 2), (8, 3), (9, 5), (10, 4);

-- Data awal: 9 peminjaman. User 3 mengembalikan Buku 7 terlambat 5 hari.
-- Tanggal dibuat tetap agar hasil contoh selalu konsisten saat query dijalankan.
INSERT INTO loans (loan_id, user_id, book_id, borrowed_at, due_at, returned_at) VALUES
    (1, 1, 1, '2025-01-01', '2025-01-14', '2025-01-14'),
    (2, 1, 2, '2025-01-01', '2025-01-14', '2025-01-14'),
    (3, 1, 3, '2025-01-01', '2025-01-14', '2025-01-14'),
    (4, 2, 4, '2025-01-02', '2025-01-15', '2025-01-15'),
    (5, 2, 5, '2025-01-02', '2025-01-15', '2025-01-15'),
    (6, 2, 6, '2025-01-02', '2025-01-15', '2025-01-15'),
    (7, 3, 7, '2025-01-03', '2025-01-16', '2025-01-21'),
    (8, 3, 8, '2025-01-03', '2025-01-16', '2025-01-16'),
    (9, 3, 9, '2025-01-03', '2025-01-16', '2025-01-16');

-- 1. Buku yang tidak pernah dipinjam.
SELECT b.title AS Buku
FROM books AS b
WHERE NOT EXISTS (
    SELECT 1
    FROM loans AS l
    WHERE l.book_id = b.book_id
)
ORDER BY b.book_id;

-- 2. Anggota yang pernah terlambat mengembalikan buku dan total dendanya.
-- Tarif denda: Rp1.000 per hari keterlambatan.
SELECT
    u.name AS `User`,
    CONCAT('Rp', SUM(DATEDIFF(l.returned_at, l.due_at) * 1000)) AS Denda
FROM users AS u
JOIN loans AS l ON l.user_id = u.user_id
WHERE l.returned_at IS NOT NULL
  AND l.returned_at > l.due_at
GROUP BY u.user_id, u.name
ORDER BY u.user_id;

-- 3. Anggota beserta daftar buku yang pernah dipinjam, dari ID buku terbesar.
SELECT
    ROW_NUMBER() OVER (ORDER BY u.user_id) AS `No`,
    u.name AS `User`,
    GROUP_CONCAT(b.title ORDER BY b.book_id DESC SEPARATOR ', ') AS Buku
FROM users AS u
JOIN loans AS l ON l.user_id = u.user_id
JOIN books AS b ON b.book_id = l.book_id
GROUP BY u.user_id, u.name
ORDER BY u.user_id;
