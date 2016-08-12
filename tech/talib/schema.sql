drop table if exists talibPattern
;

create table talibPattern(
  date datetime not null,
  code varchar(8) not null,
  pattern varchar(32) not null,
  value integer null
)
;
create unique index idx_talibPattern on talibPattern(date,code,pattern)
;
