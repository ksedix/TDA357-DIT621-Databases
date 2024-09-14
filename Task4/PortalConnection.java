
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){

        try(PreparedStatement ps = conn.prepareStatement("INSERT INTO Registrations VALUES (?,?)");) {
            ps.setString(1,student);
            ps.setString(2,courseCode);
            ps.executeUpdate();
            return "{\"success\":true}";
        } catch (SQLException e) {
          return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
      }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        String query = "DELETE FROM Registrations WHERE student='"+student+"' AND course='"+courseCode+"'";
        try(Statement s = conn.createStatement();) {

            int r = s.executeUpdate(query);
            if (r>0) {
                return "{\"success\":true}";
            } else {
                return "{\"error\":\"No student is registered/waiting for that course\"}";
            }
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\""+getError(e)+"\"}";
        }
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        try(PreparedStatement st = conn.prepareStatement(
            // replace this with something more useful
                "SELECT jsonb_build_object('student',idnr,'name',name,'login',login,'program',program,'branch',branch,'finished',(SELECT (jsonb_agg(jsonb_build_object('course',course,'credits',credits,'grade',grade))) FROM FinishedCourses WHERE student=? GROUP BY student), 'registered', (SELECT (jsonb_agg(jsonb_build_object('course',course,'status',status))) FROM Registrations WHERE student=? GROUP BY student), 'seminarCourses', (SELECT seminarCourses FROM pathToGraduation WHERE student=?),'mathCredits',(SELECT mathCredits FROM pathToGraduation WHERE student=?), 'researchCredits', (SELECT researchCredits FROM pathToGraduation WHERE student=?), 'totalCredits', (SELECT totalCredits FROM pathToGraduation WHERE student=?), 'canGraduate', (SELECT qualified FROM pathToGraduation WHERE student=?) ) AS jsondata FROM BasicInformation WHERE idnr=?"       );){

            st.setString(1, student);
            st.setString(2, student);
            st.setString(3, student);
            st.setString(4, student);
            st.setString(5, student);
            st.setString(6, student);
            st.setString(7, student);
            st.setString(8, student);
            
            ResultSet rs = st.executeQuery();
            
            if(rs.next())
              return rs.getString("jsondata");
            else
              return "{\"student\":\"does not exist :(\"}"; 
            
        } 
    }

    public void SQLInjection(String query) {
        try (Statement s = conn.createStatement();) {
            ResultSet rs = s.executeQuery(query);
        } catch (SQLException e) {
            System.out.println("error: "+getError(e));
        }
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}


