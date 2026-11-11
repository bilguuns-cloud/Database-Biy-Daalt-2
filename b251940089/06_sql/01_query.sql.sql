-- 1. INNER JOIN: Компаниуд болон тэдний зарласан ажлын байрны мэдээлэл
SELECT jp.гарчиг, comp.компанийн_нэр, jp.доод_цалин, jp.дээд_цалин
FROM Ажлын_зар jp
INNER JOIN Компани comp ON jp.компани_id = comp.компани_id;

-- 2. INNER JOIN: Ажлын байр бүрд шаардагдах ур чадварууд
SELECT jp.гарчиг, s.ур_чадварын_нэр, js.шаардагдах_түвшин
FROM Ажлын_зар jp
JOIN Зарын_ур_чадвар js ON jp.зар_id = js.зар_id
JOIN Ур_чадвар s ON js.ур_чадвар_id = s.ур_чадвар_id;

-- 3. INNER JOIN: Өргөдөл гаргасан горилогч болон зарын дэлгэрэнгүй
SELECT c.овог, c.нэр, jp.гарчиг, a.тохирлын_хувь, a.үндсэн_төлөв
FROM Өргөдөл a
JOIN Горилогч c ON a.горилогч_id = c.горилогч_id
JOIN Ажлын_зар jp ON a.зар_id = jp.зар_id;

-- 4. LEFT JOIN: Бүх горилогч болон тэдний өргөдлийн төлөв (анкет явуулаагүй нь ч орно)
SELECT c.нэр, c.овог, a.үндсэн_төлөв
FROM Горилогч c
LEFT JOIN Өргөдөл a ON c.горилогч_id = a.горилогч_id;

-- 5. LEFT JOIN: Компани бүрийн идэвхтэй зар болон ирсэн өргөдлийн тоо
SELECT comp.компанийн_нэр, 
       COUNT(DISTINCT jp.зар_id) AS идэвхтэй_зар,
       COUNT(DISTINCT a.өргөдөл_id) AS нийт_өргөдөл
FROM Компани comp
LEFT JOIN Ажлын_зар jp ON comp.компани_id = jp.компани_id AND jp.төлөв = 'Идэвхтэй'
LEFT JOIN Өргөдөл a ON jp.зар_id = a.зар_id
GROUP BY comp.компани_id, comp.компанийн_нэр;

-- 6. LEFT JOIN: Горилогч бүрийн эзэмшсэн ур чадварын жагсаалт
SELECT c.нэр, s.ур_чадварын_нэр, cs.эзэмшсэн_түвшин
FROM Горилогч c
LEFT JOIN Горилогчийн_ур_чадвар cs ON c.горилогч_id = cs.горилогч_id
LEFT JOIN Ур_чадвар s ON cs.ур_чадвар_id = s.ур_чадвар_id;

-- 7. GROUP BY + HAVING: Хамгийн их өргөдөл ирсэн эхний ажлын зарууд
SELECT j.зар_id, j.гарчиг, COUNT(a.өргөдөл_id) AS нийт_өргөдөл
FROM Ажлын_зар j
LEFT JOIN Өргөдөл a ON j.зар_id = a.зар_id
GROUP BY j.зар_id, j.гарчиг
HAVING COUNT(a.өргөдөл_id) > 0
ORDER BY нийт_өргөдөл DESC;

-- 8. GROUP BY + HAVING: Тохирлын дундаж хувь нь 75-аас дээш байгаа зарууд
SELECT jp.гарчиг, AVG(a.тохирлын_хувь)::NUMERIC(5,2) AS дундаж_тохирол
FROM Ажлын_зар jp
JOIN Өргөдөл a ON jp.зар_id = a.зар_id
GROUP BY jp.зар_id, jp.гарчиг
HAVING AVG(a.тохирлын_хувь) > 75.0;

-- 9. GROUP BY + HAVING: Илүү олон зар оруулсан компаниудыг шүүх
SELECT comp.компанийн_нэр, COUNT(jp.зар_id) AS зарын_тоо
FROM Компани comp
JOIN Ажлын_зар jp ON comp.компани_id = jp.компани_id
GROUP BY comp.компанийн_нэр
HAVING COUNT(jp.зар_id) >= 1;

-- 10. Subquery: Нийт зарын дундаж дээд цалингаас өндөр цалинтай зарууд
SELECT гарчиг, дээд_цалин
FROM Ажлын_зар
WHERE дээд_цалин > (SELECT AVG(дээд_цалин) FROM Ажлын_зар);

-- 11. Subquery: Хамгийн өндөр дээд цалинтай заранд өргөдөл өгсөн горилогчид
SELECT c.нэр, c.овог, jp.гарчиг, jp.дээд_цалин
FROM Өргөдөл a
JOIN Горилогч c ON a.горилогч_id = c.горилогч_id
JOIN Ажлын_зар jp ON a.зар_id = jp.зар_id
WHERE jp.дээд_цалин = (SELECT MAX(дээд_цалин) FROM Ажлын_зар);

-- 12. Correlated Subquery: Тухайн зарынхаа дундаж тохирлоос дээгүүр тохиролтой өргөдлүүд
SELECT a.өргөдөл_id, a.тохирлын_хувь, a.зар_id
FROM Өргөдөл a
WHERE a.тохирлын_хувь > (
    SELECT AVG(a2.тохирлын_хувь) 
    FROM Өргөдөл a2 
    WHERE a2.зар_id = a.зар_id
);

-- 13. EXISTS / NOT EXISTS: Одоогоор ярилцлагад ороогүй өргөдлүүд
SELECT a.өргөдөл_id, c.нэр, jp.гарчиг
FROM Өргөдөл a
JOIN Горилогч c ON a.горилогч_id = c.горилогч_id
JOIN Ажлын_зар jp ON a.зар_id = jp.зар_id
WHERE NOT EXISTS (
    SELECT 1 FROM Ярилцлага y WHERE y.өргөдөл_id = a.өргөдөл_id
);

-- 14. UNION / EXCEPT: Өндөр цалинтай 
SELECT гарчиг FROM Ажлын_зар WHERE дээд_цалин > 4000000
UNION
SELECT jp.гарчиг FROM Ажлын_зар jp
JOIN Зарын_ур_чадвар js ON jp.зар_id = js.зар_id
JOIN Ур_чадвар s ON js.ур_чадвар_id = s.ур_чадвар_id
WHERE s.ур_чадварын_нэр = 'PostgreSQL';

-- 15. Window Function: Ажлын заруудыг дээд цалингаар нь эрэмбэлж ранk өгөх
SELECT гарчиг, дээд_цалин,
       DENSE_RANK() OVER (ORDER BY дээд_цалин DESC) as цалингийн_рэнк
FROM Ажлын_зар;

-- 16. Window Function: Өргөдлүүдийг тохирлын хувиар нь дугаарлах
SELECT өргөдөл_id, тохирлын_хувь,
       ROW_NUMBER() OVER (ORDER BY тохирлын_хувь DESC) as эрэмбэ
FROM Өргөдөл;

-- 17. CTE (Common Table Expression): Дунджаас дээш цалинтай компаниудын жагсаалт
WITH HighSalaryJobs AS (
    SELECT компани_id, AVG(дээд_цалин) as дундаж_цалин
    FROM Ажлын_зар
    GROUP BY компани_id
)
SELECT c.компанийн_нэр, h.дундаж_цалин
FROM Компани c
JOIN HighSalaryJobs h ON c.компани_id = h.компани_id;

-- 18. Нэмэлт асуулга: Тэнцсэн төлөвтэй өргөдөл илгээсэн горилогчдын мэдээлэл
SELECT DISTINCT c.овог, c.нэр, a.үндсэн_төлөв
FROM Өргөдөл a
JOIN Горилогч c ON a.горилогч_id = c.горилогч_id
WHERE a.үндсэн_төлөв = 'Тэнцсэн';

-- 19. Нэмэлт асуулга: Компани тус бүрийн нийт цалингийн фонд
SELECT comp.компанийн_нэр, SUM(jp.дээд_цалин) AS нийт_дээд_цалин
FROM Компани comp
JOIN Ажлын_зар jp ON comp.компани_id = jp.компани_id
GROUP BY comp.компанийн_нэр;

-- 20. Нэмэлт асуулга: Хамгийн сүүлд бүртгэгдсэн 5 горилогч
SELECT овог, нэр, имэйл, бүртгэсэн_огноо
FROM Горилогч
ORDER BY бүртгэсэн_огноо DESC
LIMIT 5;