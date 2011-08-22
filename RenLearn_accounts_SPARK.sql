select SID
      ,SFIRST
      ,SLAST
      ,SGENDER
      ,SBIRTHDAY
      ,SRACE
      ,SGRADE
      ,SUSERNAME || (case when rn = 0 then null else rn end) as SUSERNAME
      ,SPASSWORD
      ,'AR' as course
      ,2024 + (-1 * (case when SGRADE = 'K' then 0 else SGRADE * 1 end)) as class
from
      (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, SRACE, SGRADE,
             SUSERNAME, SPASSWORD, row_number() over(partition by SUSERNAME
                                                         order by SGRADE, SLAST, SFIRST desc) - 1 as rn
      from
            (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, SRACE, SGRADE,
                   substr(lower(first04), 1, 1) || last04 as SUSERNAME,
                   replace(lower(first04), '''') as SPASSWORD
            from      
                  (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE 
                         ,replace(replace(last03,''''),'`') as last04
                         ,replace(replace(first03,''''),'`') as first04
                  from
                        (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE
                               ,replace(last02, ' ') as last03
                               ,replace(first02, ' ') as first03
                        from
                              (select SID, SFIRST, SLAST, SGENDER, SBIRTHDAY, ALT_BIRTHDAY, SRACE, SGRADE
                                     ,case when substr(last01, 1, instr(last01,'-',1,1)-1) is null then last01
                                           else substr(last01, 1, instr(last01,'-',1,1)-1) end last02
                                     ,replace(first01, '-') as first02                                       
                              from
                                    (select s.student_number as SID
                                           ,s.first_name as SFIRST
                                           ,s.last_name as SLAST
                                           ,s.gender as SGENDER 
                                           ,to_char(s.dob, 'mm/dd/yyyy') as SBIRTHDAY
                                           ,to_char(s.dob, 'dd') as ALT_BIRTHDAY
                                           ,s.ethnicity as SRACE
                                           ,case 
                                             when s.grade_level = 0 
                                             then 'K'
                                             else to_char(s.grade_level) end SGRADE
                                           ,case 
                                              when instr(s.last_name, ',') > 0
                                              then lower(substr(s.last_name, 1, instr(s.last_name, ',')-1))
                                              else lower(s.last_name) end last01
                                           ,case 
                                              when instr(s.first_name, ',') > 0
                                              then lower(substr(s.first_name, 1, instr(s.first_name, ',')-1))
                                              else lower(s.first_name) end first01
                                    from students s
                                    where s.enroll_status <= 0 and s.schoolid = 73254
                                    order by s.grade_level, s.lastfirst))))))
order by SGRADE desc, SLAST, SFIRST