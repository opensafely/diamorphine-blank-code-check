-- Internal project for data curation, no need for PatientsWithTypeOneDissent

;with
    cte
    as
    (
        SELECT
            dmd_id,
            year(ConsultationDate) as [year],
            month(ConsultationDate) as [month],
            cast(count(*) as float) as IssueCount
        FROM MedicationIssue i
            JOIN MedicationDictionary d
            on i.MultilexDrug_ID = d.MultilexDrug_ID
        WHERE 
            lower(d.FullName) like '%diamorph%' or
            lower(d.RootName) like '%diamorph%' or
            lower(d.FullName) like '%ayendi%' or
            lower(d.rootname) like '%ayendi'
        GROUP BY
            dmd_id,
            year(ConsultationDate),
            month(ConsultationDate)
    )

select
    dmd_id,
    [Year],
    [Month],
    CASE WHEN IssueCount=0 THEN 0 ELSE (CEILING(IssueCount/6)*6) - 3 END as IssueCount_midpoint6
from cte
order by 1,2,3