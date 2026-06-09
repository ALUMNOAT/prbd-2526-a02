CREATE OR REPLACE VIEW managerState AS
SELECT u.id, u.full_name, u.role
FROM users u
LEFT JOIN restaurant_managers rstm ON rstm.manager = u.id
LEFT JOIN restaurants rst ON rst.id = rstm.restaurant;

SELECT * FROM managerState;