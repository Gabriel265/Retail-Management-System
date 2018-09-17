
CREATE [OR REPLACE] FUNCTION change_zipcode(zipold in zipcodes.zip%type, zipnew in 
zipcodes.zip%type) as cursor c1 is select * from zipcodes where zip=zipold;

Zip_rec c1%rowtype;

begin

for zip_rec in c1 loop

exit when c1%notfound;

insert into zipcodes values (zipnew, zip_rec.city);
end loop;

update employees set zip=zipnew where zip=zipold;
update customers set zip=zipnew where zip=zipold;
delete zipcodes where zip=zipold;
end;
/

