-- Internal project for data curation, no need for PatientsWithTypeOneDissent

;with
    cte
    as
    (
        SELECT
            d.MultilexDrug_ID,
            d.dmd_id,
            d.FullName,
            year(i.ConsultationDate) as [year],
            datepart(q,i.ConsultationDate) as [quarter],
            cast(count(*) as float) as IssueCount
        FROM MedicationIssue i
            JOIN MedicationDictionary d
            on i.MultilexDrug_ID = d.MultilexDrug_ID
        WHERE 
            (lower(d.FullName) like '%diamorph%' or
            lower(d.RootName) like '%diamorph%' or
            lower(d.FullName) like '%ayendi%' or
            lower(d.rootname) like '%ayendi')
            AND ISNUMERIC(d.dmd_id) = 0
            AND NOT EXISTS (
                SELECT 1 
                FROM OpenCoronaTempTables..CustomMedicationDictionary c 
                WHERE c.MultilexDrug_ID = d.MultilexDrug_ID
            )
            AND year(i.ConsultationDate)>=2018
        GROUP BY
            d.MultilexDrug_ID,
            d.dmd_id,
            d.FullName,
            year(i.ConsultationDate),
            datepart(q,i.ConsultationDate)
    )

select
    MultilexDrug_ID,
    dmd_id,
    FullName,
    [Year],
    [Quarter],
    cast(CASE WHEN IssueCount=0 THEN 0 ELSE (CEILING(IssueCount/6)*6) - 3 END as int) as IssueCount_midpoint6
from cte
order by 1,2,3,4,5