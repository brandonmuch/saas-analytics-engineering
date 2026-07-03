select
    reporting_month,
    total_mrr,
    new_mrr + expansion_mrr + contraction_mrr + churned_mrr as calculated_change

from {{ ref('fct_mrr') }}

where total_mrr < 0