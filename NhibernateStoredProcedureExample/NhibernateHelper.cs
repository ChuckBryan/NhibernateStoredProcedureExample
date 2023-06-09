using System.Configuration;
using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;
using NHibernate;
using NhibernatePartDeux;

namespace NhibernateStoredProcedureExample
{
    public class NHibernateHelper
    {
        private static ISessionFactory _sessionFactory;

        private static ISessionFactory SessionFactory
        {
            get
            {
                if (_sessionFactory != null) return _sessionFactory;
                
                string connectionString = ConfigurationManager.ConnectionStrings["default"].ConnectionString; 
                
                FluentConfiguration configuration = Fluently.Configure()
                    .Database(MsSqlConfiguration.MsSql2008.DefaultSchema("dbo").ConnectionString(connectionString))
                    .Mappings(m =>
                    {
                        m.FluentMappings.AddFromAssemblyOf<Program>();
                        m.HbmMappings.AddFromAssemblyOf<Program>();
                        
                    })
                    .ExposeConfiguration(c=>
                    {
                        c.Properties.Add("generate_statistics", "true");
                    });

                // var configuration = new Configuration();
                // configuration.Configure(); // Looks for hibernate.cfg.xml
                _sessionFactory = configuration.BuildSessionFactory();
                return _sessionFactory;
            }
        }

        public static ISession OpenSession()
        {
            return SessionFactory.OpenSession();
        }
    }

}



