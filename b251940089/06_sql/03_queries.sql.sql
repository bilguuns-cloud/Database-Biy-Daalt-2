CREATE TABLE Компани (
    компани_id SERIAL PRIMARY KEY,
    компанийн_нэр VARCHAR(150) NOT NULL,
    регистрийн_дугаар VARCHAR(10) UNIQUE NOT NULL,
    салбар VARCHAR(100),
    холбоо_барих_имэйл VARCHAR(100)
);

CREATE TABLE Горилогч (
    горилогч_id SERIAL PRIMARY KEY,
    овог VARCHAR(50) NOT NULL,
    нэр VARCHAR(50) NOT NULL,
    имэйл VARCHAR(100) UNIQUE NOT NULL,
    утас VARCHAR(20),
    бүртгэсэн_огноо TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Ур_чадвар (
    ур_чадвар_id SERIAL PRIMARY KEY,
    ур_чадварын_нэр VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Ажлын_зар (
    зар_id SERIAL PRIMARY KEY,
    компани_id INT NOT NULL REFERENCES Компани(компани_id) ON DELETE CASCADE,
    гарчиг VARCHAR(150) NOT NULL,
    сул_орон_тооны_тоо INT DEFAULT 1 CHECK (сул_орон_тооны_тоо >= 0),
    тавигдах_шаардлага TEXT,
    доод_цалин DECIMAL(12,2) CHECK (доод_цалин >= 0),
    дээд_цалин DECIMAL(12,2) CHECK (дээд_цалин >= доод_цалин),
    төлөв VARCHAR(20) DEFAULT 'Идэвхтэй' CHECK (төлөв IN ('Идэвхтэй', 'Хаагдсан', 'Цуцлагдсан')),
    үүсгэсэн_огноо DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Ажлын_туршлага (
    туршлага_id SERIAL PRIMARY KEY,
    горилогч_id INT NOT NULL REFERENCES Горилогч(горилогч_id) ON DELETE CASCADE,
    байгууллагын_нэр VARCHAR(150) NOT NULL,
    албан_тушаал VARCHAR(100) NOT NULL,
    эхлэх_огноо DATE NOT NULL,
    дуусах_огноо DATE,
    CONSTRAINT chk_dates CHECK (дуусах_огноо IS NULL OR эхлэх_огноо <= дуусах_огноо)
);

CREATE TABLE Боловсрол (
    боловсрол_id SERIAL PRIMARY KEY,
    горилогч_id INT NOT NULL REFERENCES Горилогч(горилогч_id) ON DELETE CASCADE,
    сургуулийн_нэр VARCHAR(150) NOT NULL,
    зэрэг VARCHAR(50) NOT NULL,
    мэргэжил VARCHAR(100) NOT NULL,
    төгссөн_жил INT
);

CREATE TABLE Зарын_ур_чадвар (
    зар_id INT REFERENCES Ажлын_зар(зар_id) ON DELETE CASCADE,
    ур_чадвар_id INT REFERENCES Ур_чадвар(ур_чадвар_id) ON DELETE CASCADE,
    шаардагдах_түвшин INT CHECK (шаардагдах_түвшин BETWEEN 1 AND 5),
    PRIMARY KEY (зар_id, ур_чадвар_id)
);

CREATE TABLE Горилогчийн_ур_чадвар (
    горилогч_id INT REFERENCES Горилогч(горилогч_id) ON DELETE CASCADE,
    ур_чадвар_id INT REFERENCES Ур_чадвар(ур_чадвар_id) ON DELETE CASCADE,
    эзэмшсэн_түвшин INT CHECK (эзэмшсэн_түвшин BETWEEN 1 AND 5),
    туршлагын_жил INT CHECK (туршлагын_жил >= 0),
    PRIMARY KEY (горилогч_id, ур_чадвар_id)
);

CREATE TABLE Өргөдөл (
    өргөдөл_id SERIAL PRIMARY KEY,
    зар_id INT NOT NULL REFERENCES Ажлын_зар(зар_id) ON DELETE CASCADE,
    горилогч_id INT NOT NULL REFERENCES Горилогч(горилогч_id) ON DELETE CASCADE,
    тохирлын_хувь DECIMAL(5,2) DEFAULT 0.0,
    үндсэн_төлөв VARCHAR(30) DEFAULT 'Илгээсэн',
    илгээсэн_огноо TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_candidate_job UNIQUE (зар_id, горилогч_id)
);

CREATE TABLE Төлөвийн_түүх (
    түүх_id SERIAL PRIMARY KEY,
    өргөдөл_id INT NOT NULL REFERENCES Өргөдөл(өргөдөл_id) ON DELETE CASCADE,
    төлөв VARCHAR(30) NOT NULL,
    өөрчилсөн_огноо TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    тайлбар TEXT
);

CREATE TABLE Ярилцлага (
    ярилцлага_id SERIAL PRIMARY KEY,
    өргөдөл_id INT NOT NULL REFERENCES Өргөдөл(өргөдөл_id) ON DELETE CASCADE,
    ярилцлага_авсан_hr VARCHAR(100) NOT NULL,
    товлосон_цаг TIMESTAMP NOT NULL,
    байршил_эсвэл_холбоос VARCHAR(255),
    үр_дүн VARCHAR(30) DEFAULT 'Хүлээгдэж буй'
);