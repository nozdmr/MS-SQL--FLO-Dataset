---  2. Ka� farkl� m��terinin al��veri� yapt���n� g�sterecek sorguyu yaz�n�z.

SELECT COUNT(DISTINCT master_id) from FLO

-- 3. Toplam yap�lan al��veri� say�s� ve ciroyu getirecek sorguyu yaz�n�z.

SELECT SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Toplam Al��veri� Say�s�', 
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro' 

FROM FLO

-- 4. Al��veri� ba��na ortalama ciroyu getirecek sorguyu yaz�n�z.

SELECT ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2)
FROM FLO

--- 5. En son al��veri� yap�lan kanal (last_order_channel) �zerinden yap�lan al��veri�lerin toplam ciro ve al��veri� say�lar�n�
--  getirecek sorguyu yaz�n�z.

SELECT last_order_channel AS 'SON ALI�VER�� KANALI', SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Toplam Al��veri� Say�s�', 
		SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro' 
FROM FLO
GROUP BY last_order_channel

--- 6. Store type k�r�l�m�nda elde edilen toplam ciroyu getiren sorguyu yaz�n�z.

SELECT store_type, SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'Toplam Ciro',
ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2)
FROM FLO
GROUP BY store_type

---- 7. Y�l k�r�l�m�nda al��veri� say�lar�n� getirecek sorguyu yaz�n�z (Y�l olarak m��terinin ilk al��veri� tarihi (first_order_date) y�l�n�
--- baz al�n�z)

SELECT DATEPART(year, first_order_date) AS 'YIL', SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'Al��veri� Say�s�'
FROM FLO
GROUP BY DATEPART(year, first_order_date)
ORDER BY DATEPART(year, first_order_date)

-- 8. En son al��veri� yap�lan kanal k�r�l�m�nda al��veri� ba��na ortalama ciroyu hesaplayacak sorguyu yaz�n�z.

SELECT last_order_channel as 'Son Al��veri� Kanal�', 
ROUND( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline),2) AS 'Al��veri� Ba��na Ciro'
FROM FLO
GROUP BY last_order_channel

-- 9. Son 12 ayda en �ok ilgi g�ren kategoriyi getiren sorguyu yaz�n�z.

SELECT interested_in_categories_12, COUNT(*) AS 'FREKANS B�LG�S�'
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY COUNT(*) DESC

-- 10. En �ok tercih edilen store_type bilgisini getiren sorguyu yaz�n�z.
SELECT TOP 1 store_type, COUNT(*) AS 'Frekans Bilgisi'
FROM FLO 
GROUP BY store_type
ORDER BY 2 DESC

--- 11. En son al��veri� yap�lan kanal (last_order_channel) baz�nda, en �ok ilgi g�ren kategoriyi ve bu kategoriden ne kadarl�k
-- al��veri� yap�ld���n� getiren sorguyu yaz�n�z.

SELECT DISTINCT last_order_channel ,
	
	( SELECT TOP 1 interested_in_categories_12 
	  FROM FLO
	  WHERE last_order_channel = F.last_order_channel
	  GROUP BY interested_in_categories_12
	  Order by SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC
	) AS 'KATEGOR�',
	( SELECT TOP 1 SUM(order_num_total_ever_offline + order_num_total_ever_online)
	  FROM FLO
	  WHERE last_order_channel = F.last_order_channel
	  GROUP BY interested_in_categories_12
	  ORDER BY  SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC) AS 'ALI� VER�� SAYISI'

FROM FLO F 
GROUP BY last_order_channel

--- 12. En �ok al��veri� yapan ki�inin ID� sini getiren sorguyu yaz�n�z.
 SELECT TOP 1 master_id 
 FROM FLO 
 GROUP BY master_id 
 ORDER BY SUM(order_num_total_ever_offline + order_num_total_ever_online) DESC


 --13. En �ok al��veri� yapan ki�inin al��veri� ba��na ortalama cirosunu ve al��veri� yapma g�n ortalamas�n� (al��veri� s�kl���n�)
--- getiren sorguyu yaz�n�z.

SELECT master_id, first_order_date , last_order_date, 
	SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'TOPLAM_C�RO', 
	SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'TOPLAM_S�PAR��_SAYISI',
	ROUND ( SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / SUM(order_num_total_ever_online + order_num_total_ever_offline) ,2) AS 'ALI�VER�� BA�INA ORT C�RO',
	DATEDIFF(DAY, first_order_date, last_order_date) AS '�lk-Son Sipari� G�n Fark�',
	ROUND( SUM(order_num_total_ever_online + order_num_total_ever_offline) / DATEDIFF(DAY, first_order_date, last_order_date), 2) AS 'ALI�VER�� YAPMA G�N ORTALAMASI'
FROM FLO
WHERE master_id = ( SELECT TOP 1  master_id FROM flo GROUP BY master_id  ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC)
GROUP BY  master_id, first_order_date , last_order_date


--- 14. En �ok al��veri� yapan (ciro baz�nda) ilk 100 ki�inin al��veri� yapma g�n ortalamas�n� (al��veri� s�kl���n�) getiren sorguyu
---- yaz�n�z.

SELECT d.master_id, d.first_order_date,d.first_order_date, TOPLAM_S�PAR��_SAYISI, 
		DATEDIFF(DAY, first_order_date, last_order_date) AS 'Sipari�ler aras� g�n fark�',
		ROUND( TOPLAM_S�PAR��_SAYISI /  DATEDIFF(DAY, first_order_date, last_order_date), 2)  

FROM 
	( SELECT TOP 100 master_id , first_order_date, last_order_date, 
			SUM(customer_value_total_ever_online + customer_value_total_ever_offline) AS 'TOPLAM_C�RO',
			SUM(order_num_total_ever_online + order_num_total_ever_offline) AS 'TOPLAM_S�PAR��_SAYISI'
			
			FROM FLO
			GROUP BY master_id, first_order_date, last_order_date
			ORDER BY SUM(customer_value_total_ever_online + customer_value_total_ever_offline) DESC
			) D 

---- 15. En son al��veri� yap�lan kanal (last_order_channel) k�r�l�m�nda en �ok al��veri� yapan m��teriyi getiren sorguyu yaz�n�z.

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


-- 16. En son al��veri� yapan ki�inin ID� sini getiren sorguyu yaz�n�z. (Max son tarihte birden fazla al��veri� yapan ID bulunmakta.
-- Bunlar� da getiriniz.)

SELECT DISTINCT master_id,last_order_date
FROM FLO
WHERE last_order_date = ( SELECT MAX(last_order_date) FROM  FLO )


