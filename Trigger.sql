POSTGRESQL TRIGGERS & FUNCTIONS

1.Check the age of Employee
CREATE TRIGGER check_age BEFORE INSERT ON Employees
FOR EACH ROW EXECUTE PROCEDURE ageofemp();

CREATE OR REPLACE FUNCTION ageofemp() RETURNS TRIGGER AS $example_table$
	DECLARE years_old integer;
	BEGIN
		years_old=((CURRENT_DATE-NEW.bdate)/365);
		IF (years_old) < 18 THEN	
			RAISE EXCEPTION 'Underage man';
		END IF;
		return new;
	END;
$example_table$ LANGUAGE plpgsql;



2.No Late Sale of items:
CREATE TRIGGER no_late_sale BEFORE INSERT ON Transactions
FOR EACH ROW EXECUTE PROCEDURE nolatesaleitems();

CREATE OR REPLACE FUNCTION nolatesaleitems() RETURNS TRIGGER AS $example_table1$
BEGIN
	if (CURRENT_DATE) > (to_date(to_char(CURRENT_DATE,'MM-DD-YYYY') || ' 20:00:00', 'MM-DD-YYYY HH24:MI:SS')) then
		INSERT INTO Errorlog values (SEQ_USER_ID.nextval, 'NO late sale',CURRENT_DATE);
	END IF;
	return new;
END;
$example_table1$ LANGUAGE plpgsql;


BUSINESS RULE TRIGGERS:

1.Checking Inventory:
CREATE TRIGGER check_inventory BEFORE UPDATE ON Sales
FOR EACH ROW EXECUTE PROCEDURE checkinv();

CREATE OR REPLACE FUNCTION checkinv() RETURNS TRIGGER AS $example_table2$
DECLARE 
	quant integer;
    dnumber integer;
    snumber integer;
    uprice integer;
    tempNum integer;     
	i_cur CURSOR FOR SELECT quantityinhand,deptnumber,suppliernumber,unitprice from Inventory 
	where itemnumber=NEW.itemnumber;       
BEGIN
	OPEN i_cur;
    FETCH i_cur into quant, dnumber, snumber, uprice;
	quant = quantityinhand-NEW.qty;
	if (quant  = 10) then
		insert into Orders values(SEQ_USER_ID.nextval, snumber, CURRENT_DATE) ;
		insert into SupplierOrder values(((SEQ_USER_ID.nextval)),((SEQ_USER_ID.nextval)-2), 2, 50, uprice);
	end if;
	close i_cur;
END;
$example_table2$ LANGUAGE plpgsql;

2. Checking the store card:

CREATE TRIGGER check_store_card AFTER INSERT ON Transactions
FOR EACH ROW EXECUTE PROCEDURE checkstore();

CREATE OR REPLACE FUNCTION checkstore() RETURNS TRIGGER AS $example_table3$
BEGIN
	if (NEW.storecard = 'y') then
		UPDATE Transactions	
		set amount = amount-(amount * 0.1)
		where transactionid =NEW.transactionid;
	END IF;
END;
$example_table3$ LANGUAGE plpgsql;

3.Checking the order :
CREATE TRIGGER order_check BEFORE INSERT ON supplierOrder
FOR EACH ROW EXECUTE PROCEDURE checkorder();

CREATE OR REPLACE FUNCTION checkorder() RETURNS TRIGGER AS $example_table4$
BEGIN
	IF (NEW.qty) > 50 THEN
		INSERT INTO Errorlog values(SEQ_USER_ID.nextval, 'SHOULD NOT ORDER MORE THAN 50',CURRENT_DATE);
		DELETE FROM orders where orderno=NEW.supplierorderid;
	END IF;
END;
$example_table4$ LANGUAGE plpgsql;


4.Cannot return a item which is sold after certain days:

CREATE TRIGGER not_return BEFORE INSERT ON Return1
FOR EACH ROW EXECUTE PROCEDURE noreturns();

CREATE OR REPLACE FUNCTION noreturns() RETURNS TRIGGER AS $example_table5$
	DECLARE 
		dt date;
		cur1 CURSOR FOR SELECT dateoftransaction FROM Transactions where transactionid =NEW.transactionid;
	begin
		OPEN cur1;
		FETCH cur1 into dt;
		if((CURRENT_DATE-dt) > 10) then
			RAISE EXCEPTION 'you can not return, more than 10 days';
		end if;
		close cur1;
	end;
$example_table5$ LANGUAGE plpgsql;

5.Same Manager cannot be allocated to two different location:

CREATE TRIGGER mgr_on_loc BEFORE INSERT ON location
FOR EACH ROW EXECUTE PROCEDURE notallowed();

CREATE OR REPLACE FUNCTION notallowed() RETURNS TRIGGER AS $example_table6$
	DECLARE 
		id integer;
		errormsg varchar(300); 	
		cur1 CURSOR FOR select locationnumber from location where lmgrssn =new.lmgrssn;
	BEGIN
		id=0;
		errormsg='delete';
		OPEN cur1;
		FETCH cur1 into id;
		if (id >0) then
			RAISE EXCEPTION 'errormsg';	    
		END IF;
		close cur1;
	END;
$example_table6$ LANGUAGE plpgsql;

6.Cannot Sell Item on a particular day:

CREATE TRIGGER can_not_sell BEFORE INSERT ON Sales
FOR EACH ROW EXECUTE PROCEDURE nosale();

CREATE OR REPLACE FUNCTION nosale() RETURNS TRIGGER AS $example_table7$
	DECLARE 
		desc1 varchar(40); 
		p_cur CURSOR FOR select description from PriceLookUp where itemnumber=new.itemnumber;	
	BEGIN
    	open p_cur;
		FETCH p_cur into desc1;
	 		RAISE DEBUG 'to_char(CURRENT_DATE,Day)';
	 		RAISE DEBUG 'desc1';
		if (to_char(CURRENT_DATE,'Day')!=desc1) then
			RAISE DEBUG 'desc1';		
		else
			RAISE EXCEPTION 'you can not return, more than 10 days';
		end if;
		close p_cur;
	END;
$example_table7$ LANGUAGE plpgsql;


LOGIC RULES:
1.Determining the Total Sales :

CREATE TRIGGER total_sales BEFORE INSERT ON TotalSale
FOR EACH ROW EXECUTE PROCEDURE totalsales();

CREATE OR REPLACE FUNCTION totalsales() RETURNS TRIGGER AS $example_table8$
	DECLARE	
		c1 CURSOR FOR select * from transactions where dateoftransaction=CURRENT_DATE;
		acct c1%ROWTYPE;
		total integer;
	BEGIN
		open c1;
		total=0;
		for acct in c1 loop
			exit if c1 not found then;
			total= total + acct.amount;
		end loop;
		insert into totalsale values(SEQ_USER_ID.nextval, total, CURRENT_DATE);
	END;
$example_table8$ LANGUAGE plpgsql;