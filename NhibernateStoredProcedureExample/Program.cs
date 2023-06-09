using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ConsoleTables;
using NHibernate;
using NHibernate.Hql.Ast.ANTLR.Tree;
using NHibernate.Transform;
using NhibernateStoredProcedureExample;

namespace NhibernatePartDeux
{
    internal class Program
    {
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("===Starting Up ====");
                
                using (ISession session = NHibernateHelper.OpenSession())
                {
                    IQuery nhQuery = session.GetNamedQuery("TimeSheetSummaryQuery")
                        .SetParameter("UserID", 55, NHibernateUtil.Int32)
                        .SetParameter("ProjectID", null, NHibernateUtil.Int32)
                        .SetParameter("InvoiceTypeID", null, NHibernateUtil.Int32)
                        .SetParameter("BillCycleID", 1)
                        .SetParameter("IncludeNonBill", true)
                        .SetParameter("PeriodEnding", new DateTime(2012, 11, 10))
                        .SetResultTransformer(Transformers.AliasToBean<TimeSheetSummary>());
                    
                    var summaries = nhQuery.List<TimeSheetSummary>();

                    ConsoleTable
                        .From<TimeSheetSummary>(summaries)
                        .Configure(o => o.NumberAlignment = Alignment.Right)
                        .Write(Format.Alternative);

        
                    Console.WriteLine("");
                    Console.WriteLine("============================");
                    Console.WriteLine("===Press any key to exit.===");
                    Console.WriteLine("============================");
                    Console.WriteLine("");

                    Console.ReadLine();
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
        }
    }
}