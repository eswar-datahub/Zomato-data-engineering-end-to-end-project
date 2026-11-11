SELECT 
    user_id::number as customer_id,
    name AS customer_name,
    lower(email) AS email,
    try_to_number(age) AS age,
    gender,
    marital_status,
    occupation,
    monthly_income AS income_band,
    education,
    try_to_number(family_size) AS family_size
FROM {{ source('raw', 'users') }} WHERE try_to_number(user_id) is not null