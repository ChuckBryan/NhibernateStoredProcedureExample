using FluentNHibernate.Data;
using System;
using System.Globalization;

namespace NhibernatePartDeux
{
    public class TimeSheetSummary
    {
        public virtual int ClientId { get; set; }
        public virtual string DisplayName { get; set; }
        public virtual string Name { get; set; }
        public virtual DateTime PeriodEnding { get; set; }
        public virtual string BillCycle { get; set; }
        public virtual string InvoiceType { get; set; }
        public virtual decimal PeriodHours { get; set; }
        public virtual decimal BillableHours { get; set; }
        public virtual decimal NonBillableHours { get; set; }
    }
}