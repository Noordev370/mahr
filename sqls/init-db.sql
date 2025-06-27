/* bussiness constraints that is vey detailed will be implemented in backend code and frontend.
   costaints like the car model should be between 1970 and the current year.
   car marks and colors shold be a definit set of values (enum) etc
   as they chage frequntly and are sophisticated in nature
*/


create table users( username text unique NOT NULL,
                    password text NOT NULL,
                    bio text NOT NULL,
                    picture_file_name text unique NOT NULL);

create table cars( id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
                   mark TEXT NOT NULL,
                   model integer NOT NULL,
                   price integer check (price > 0) NOT NULL,
                   color TEXT NOT NULL,
                   status TEXT NOT NULL,
                   picture_file_name TEXT unique NOT NULL);
