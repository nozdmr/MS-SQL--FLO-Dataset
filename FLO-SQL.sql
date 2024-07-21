---  2. Kaç farklý müþterinin alýþveriþ yaptýðýný gösterecek sorguyu yazýnýz.

SELECT COUNT(DISTINCT master_id) from FLO

-- 3. Toplam yapýlan alýþveriþ sayýsý ve ciroyu getirecek sorguyu yazýnýz.

SELECT SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Toplam Alýþveriþ Sayýsý', 
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro' 

FROM FLO

-- 4. Alýþveriþ baþýna ortalama ciroyu getirecek sorguyu yazýnýz.

SELECT ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2)
FROM FLO

--- 5. En son alýþveriþ yapýlan kanal (last_order_channel) üzerinden yapýlan alýþveriþlerin toplam ciro ve alýþveriþ sayýlarýný
--  getirecek sorguyu yazýnýz.

SELECT last_order_channel AS 'SON ALIÞVERÝÞ KANALI', SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Toplam Alýþveriþ Sayýsý', 
		SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro' 
FROM FLO
GROUP BY last_order_channel

--- 6. Store type kýrýlýmýnda elde edilen toplam ciroyu getiren sorguyu yazýnýz.

SELECT store_type, SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro',
ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2)
FROM FLO
GROUP BY store_type

---- 7. Yýl kýrýlýmýnda alýþveriþ sayýlarýný getirecek sorguyu yazýnýz (Yýl olarak müþterinin ilk alýþveriþ tarihi (first_order_date) yýlýný
--- baz alýnýz)

SELECT DATEPART(year, first_order_date) AS 'YIL', SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Alýþveriþ Sayýsý'
FROM FLO
GROUP BY DATEPART(year, first_order_date)
ORDER BY DATEPART(year, first_order_date)

-- 8. En son alýþveriþ yapýlan kanal kýrýlýmýnda alýþveriþ baþýna ortalama ciroyu hesaplayacak sorguyu yazýnýz.

SELECT last_order_channel as 'Son Alýþveriþ Kanalý', 
ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2) AS 'Alýþveriþ Baþýna Ciro'
FROM FLO
GROUP BY last_order_channel

-- 9. Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazýnýz.

SELECT interested_in_categories_12, COUNT(*) AS 'FREKANS BÝLGÝSÝ'
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY COUNT(*) DESC

-- 10. En çok tercih edilen store_type bilgisini getiren sorguyu yazýnýz.
SELECT TOP 1 store_type, COUNT(*) AS 'Frekans Bilgisi'
FROM FLO 
GROUP BY store_type
ORDER BY 2 DESC

--- 11. En son alýþveriþ yapýlan kanal (last_order_channel) bazýnda, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlýk
-- alýþveriþ yapýldýðýný getiren sorguyu yazýnýz.

SELECT DISTINCT last_order_channel ,
	
	( SELECT TOP 1 interested_in_categories_12 
	  FROM FLO
	  WHERE last_order_channel = F.last_order_channel
	  GROUP BY interested_in_categories_12
	  Order by SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC
	) AS 'KATEGORÝ',
	( SELECT TOP 1 SUM(order_num_total_ever_offline + order_num_total_ever_online)
	  FROM FLO
	  WHERE last_order_channel = F.last_order_channel
	  GROUP BY interested_in_categories_12
	  ORDER BY  SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC) AS 'ALIÞ VERÝÞ SAYISI'

FROM FLO F 
GROUP BY last_order_channel

--- 12. En çok alýþveriþ yapan kiþinin ID’ sini getiren sorguyu yazýnýz.
 SELECT TOP 1 master_id 
 FROM FLO 
 GROUP BY master_id 
 ORDER BY SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC


 --13. En çok alýþveriþ yapan kiþinin alýþveriþ baþýna ortalama cirosunu ve alýþveriþ yapma gün ortalamasýný (alýþveriþ sýklýðýný)
--- getiren sorguyu yazýnýz.

SELECT master_id, first_order_date , last_order_date, 
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'TOPLAM_CÝRO', 
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'TOPLAM_SÝPARÝÞ_SAYISI',
	ROUND ( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline) ,2) AS 'ALIÞVERÝÞ BAÞINA ORT CÝRO',
	DATEDIFF(DAY, first_order_date, last_order_date) AS 'Ýlk-Son Sipariþ Gün Farký',
	ROUND( SUM(order_num_total_ever_online + order_num_total_ever_offline) / DATEDIFF(DAY, first_order_date, last_order_date), 2) AS 'ALIÞVERÝÞ YAPMA GÜN ORTALAMASI'
FROM FLO
WHERE master_id = ( SELECT TOP 1  master_id FROM flo GROUP BY master_id  ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC)
GROUP BY  master_id, first_order_date , last_order_date


--- 14. En çok alýþveriþ yapan (ciro bazýnda) ilk 100 kiþinin alýþveriþ yapma gün ortalamasýný (alýþveriþ sýklýðýný) getiren sorguyu
---- yazýnýz.

SELECT d.master_id, d.first_order_date,d.first_order_date, TOPLAM_SÝPARÝÞ_SAYISI, 
		DATEDIFF(DAY, first_order_date, last_order_date) AS 'Sipariþler arasý gün farký',
		ROUND( TOPLAM_SÝPARÝÞ_SAYISI /  DATEDIFF(DAY, first_order_date, last_order_date), 2)  

FROM 
	( SELECT TOP 100 master_id , first_order_date, last_order_date, 
			SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'TOPLAM_CÝRO',
			SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'TOPLAM_SÝPARÝÞ_SAYISI'
			
			FROM FLO
			GROUP BY master_id, first_order_date, last_order_date
			ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC
			) D 

---- 15. En son alýþveriþ yapýlan kanal (last_order_channel) kýrýlýmýnda en çok alýþveriþ yapan müþteriyi getiren sorguyu yazýnýz.

SELECT last_order_channel , 
( SELECT TOP 1 master_id  
	  FROM FLO 
	  WHERE last_order_channel = F.last_order_channel 
	  GROUP BY master_id 
	  ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline)  DESC) AS 'MASTER ID', 

( SELECT TOP 1 SUM(customer_value_total_ever_online + customer_value_total_ever_offline) 
		FROM FLO
		WHERE last_order_channel = F.last_order_channel
		GROUP BY master_id
		ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC) AS 'Toplam Ciro'

FROM FLO F
GROUP BY last_order_channel 


-- 16. En son alýþveriþ yapan kiþinin ID’ sini getiren sorguyu yazýnýz. (Max son tarihte birden fazla alýþveriþ yapan ID bulunmakta.
-- Bunlarý da getiriniz.)

SELECT DISTINCT master_id,last_order_date
FROM FLO
WHERE last_order_date = ( SELECT MAX(last_order_date) FROM  FLO )


