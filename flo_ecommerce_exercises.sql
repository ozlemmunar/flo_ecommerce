SELECT * FROM `flo_ecommerce.ecommerce`

-- Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT 
COUNT (DISTINCT master_id) 
FROM `flo_ecommerce.ecommerce`


-- Toplam yapılan alışveriş sayısı ve ciroyu getirecek sorguyu yazınız.
SELECT 
SUM (order_num_total_ever_offline + order_num_total_ever_online) AS toplam_siparis_sayisi,
ROUND ( SUM (customer_value_total_ever_offline + customer_value_total_ever_online),2) AS toplam_ciro
FROM `flo_ecommerce.ecommerce`


-- Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.
SELECT  
ROUND((SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / 
SUM(order_num_total_ever_online+order_num_total_ever_offline) ), 2) AS SIPARIS_ORT_CIRO 
FROM `flo_ecommerce.ecommerce`



-- En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.
SELECT 
last_order_channel AS son_alisveris_kanali,
SUM (order_num_total_ever_offline + order_num_total_ever_online) AS toplam_siparis_sayisi,
ROUND ( SUM (customer_value_total_ever_offline + customer_value_total_ever_online),2) AS toplam_ciro
FROM `flo_ecommerce.ecommerce`
GROUP BY last_order_channel


-- Store type kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.
SELECT store_type,
ROUND ( SUM (customer_value_total_ever_offline + customer_value_total_ever_online),2) AS toplam_ciro
FROM `flo_ecommerce.ecommerce`
GROUP BY store_type


-- Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Yıl olarak müşterinin ilk alışveriş tarihi (first_order_date) yılını baz alınız)
SELECT 
EXTRACT (YEAR FROM  first_order_date) AS order_year ,
SUM ( order_num_total_ever_online + order_num_total_ever_offline )
FROM `flo_ecommerce.ecommerce`
GROUP BY order_year
ORDER BY order_year


-- En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.
SELECT
last_order_channel,
ROUND(SUM(customer_value_total_ever_offline) + SUM(customer_value_total_ever_online), 2) AS toplam_ciro,
SUM(order_num_total_ever_offline) + SUM(order_num_total_ever_online) AS toplam_siparis_sayisi,
ROUND((SUM(customer_value_total_ever_offline) + SUM(customer_value_total_ever_online)) / (SUM(order_num_total_ever_offline) + SUM(order_num_total_ever_online)), 2) AS verimlilik
FROM `flo_ecommerce.ecommerce`
GROUP BY last_order_channel


-- Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız. 
SELECT 
interested_in_categories_12,
COUNT (*) frekans_bilgisi
FROM `flo_ecommerce.ecommerce`
GROUP BY interested_in_categories_12
ORDER BY 2 DESC


-- En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.
SELECT
store_type,
COUNT (*) frekans_bilgisi
FROM `flo_ecommerce.ecommerce`
GROUP BY store_type
ORDER BY 2 DESC
LIMIT 1


-- En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık alışveriş yapıldığını getiren sorguyu yazınız.
WITH category_data AS (
  SELECT
    last_order_channel,
    interested_in_categories_12,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS total_value
  FROM `flo_ecommerce.ecommerce`
  GROUP BY last_order_channel, interested_in_categories_12
)

SELECT
  last_order_channel,
  interested_in_categories_12 AS most_popular_category,
  total_value AS most_popular_category_value
FROM category_data
WHERE total_value = (
  SELECT MAX(total_value)
  FROM category_data c
  WHERE c.last_order_channel = category_data.last_order_channel
)
ORDER BY last_order_channel;


-- En çok alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız.
SELECT
master_id
FROM `flo_ecommerce.ecommerce`
GROUP BY master_id
ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC
LIMIT 1


-- En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.
SELECT 
  D.master_id,
  ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2) AS SIPARIS_BASINA_ORTALAMA,
  ROUND((DATE_DIFF(D.last_order_date, D.first_order_date, DAY) / D.TOPLAM_SIPARIS_SAYISI), 1) AS ALISVERIS_GUN_ORT
FROM (
  SELECT 
    master_id, 
    first_order_date, 
    last_order_date,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYISI
  FROM `flo_ecommerce.ecommerce`
  GROUP BY master_id, first_order_date, last_order_date
  ORDER BY TOPLAM_CIRO DESC
  LIMIT 1
) D;


-- En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız. 
SELECT  
  D.master_id,
  D.TOPLAM_CIRO,
  D.TOPLAM_SIPARIS_SAYISI,
  ROUND((D.TOPLAM_CIRO / D.TOPLAM_SIPARIS_SAYISI), 2) AS SIPARIS_BASINA_ORTALAMA,
  DATE_DIFF(D.last_order_date, D.first_order_date, DAY) AS ILK_SN_ALVRS_GUN_FRK,
  ROUND((DATE_DIFF(D.last_order_date, D.first_order_date, DAY) / D.TOPLAM_SIPARIS_SAYISI), 1) AS ALISVERIS_GUN_ORT
FROM (
  SELECT 
    master_id, 
    first_order_date, 
    last_order_date,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYISI
  FROM `flo_ecommerce.ecommerce`
  GROUP BY master_id, first_order_date, last_order_date
  ORDER BY TOPLAM_CIRO DESC
  LIMIT 100
) D;


-- En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız.
WITH ranked_sales AS (
  SELECT 
    last_order_channel,
    master_id,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS total_value
  FROM `flo_ecommerce.ecommerce`
  GROUP BY last_order_channel, master_id
),
ranked_channels AS (
  SELECT 
    last_order_channel,
    master_id,
    total_value,
    ROW_NUMBER() OVER (PARTITION BY last_order_channel ORDER BY total_value DESC) AS rn
  FROM ranked_sales
)

SELECT 
  f1.last_order_channel,
  f2.master_id AS EN_COK_ALISVERIS_YAPAN_MUSTERI,
  f2.total_value AS CIRO
FROM `flo_ecommerce.ecommerce` AS f1
JOIN ranked_channels AS f2
  ON f1.last_order_channel = f2.last_order_channel
  AND f2.rn = 1
GROUP BY f1.last_order_channel, f2.master_id, f2.total_value;


-- En son alışveriş yapan kişinin ID’ sini getiren sorguyu yazınız. (Max son tarihte birden fazla alışveriş yapan ID bulunmakta. Bunları da getiriniz.)
SELECT master_id,last_order_date FROM `flo_ecommerce.ecommerce` 
WHERE last_order_date=(SELECT MAX(last_order_date) FROM `flo_ecommerce.ecommerce` )















