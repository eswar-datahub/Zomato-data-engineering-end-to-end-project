USE ROLE ACCOUNTADMIN;
USE DATABASE ZOMATO;
USE SCHEMA RAW;

-- CREATING A SCHEMA FOR RESTAURANT TABLE

CREATE OR REPLACE TABLE RAW.restaurants (
  _idx          STRING,                    -- leading index column in the CSV (ignoreddownstream)
  id            STRING, 
  name          STRING, 
  city          STRING, 
  rating        STRING,
  rating_count  STRING, 
  cost          STRING, 
  cuisine       STRING, 
  lic_no        STRING,
  link          STRING, 
  address       STRING, 
  menu          STRING
);

-- CREATING A SCHEMA FOR USERS TABLE
CREATE OR REPLACE TABLE RAW.users (
  _idx STRING,                             -- leading index column in the CSV
  user_id STRING, 
  name STRING, 
  email STRING, 
  password STRING, 
  age STRING,
  gender STRING, 
  marital_status STRING, 
  occupation STRING, 
  monthly_income STRING,
  education STRING, 
  family_size STRING
);

-- CREATING A SCHEMA FOR FOOD TABLE

CREATE OR REPLACE TABLE RAW.food (
  _idx STRING,                             -- leading index column in the CSV
  f_id STRING, 
  item STRING, 
  veg_or_non_veg STRING
);

-- CREATING A SCHEMA FOR MENU TABLE

CREATE OR REPLACE TABLE RAW.menu (
  _idx STRING,                             -- leading index column in the CSV
  menu_id STRING, 
  r_id STRING, 
  f_id STRING, 
  cuisine STRING, 
  price STRING
);


-- CREATING A SCHEMA FOR ORDERS TABLE
CREATE OR REPLACE TABLE RAW.orders (
  order_id          NUMBER,
  order_timestamp   TIMESTAMP_NTZ,
  order_date        DATE,
  user_id           NUMBER,
  r_id              NUMBER,
  restaurant_city   STRING,
  cuisine           STRING,
  items_count       NUMBER,
  sales_qty         NUMBER,
  subtotal          NUMBER,
  discount          NUMBER,
  delivery_fee      NUMBER,
  gst               NUMBER,
  sales_amount      NUMBER,
  currency          STRING,
  payment_method    STRING,
  order_status      STRING,
  customer_rating   NUMBER,
  delivery_time_min NUMBER
);

-- CREATING A SCHEMA FOR ORDER_ITEMS TABLE

CREATE OR REPLACE TABLE RAW.order_items (
  order_item_id NUMBER,
  order_id      NUMBER,
  r_id          NUMBER,
  f_id          STRING,
  price         NUMBER,
  quantity      NUMBER,
  line_amount   NUMBER
);

-- CREATING A SCHEMA FOR REVIEW TABLE


CREATE OR REPLACE TABLE RAW.reviews (
  review_id     NUMBER,
  order_id      NUMBER,
  user_id       NUMBER,
  restaurant_id NUMBER,
  rating        NUMBER,
  comment       STRING,
  review_date   DATE
);

