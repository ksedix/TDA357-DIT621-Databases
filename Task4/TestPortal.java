public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
   
          // Write your tests here. Add/remove calls to pause() as desired.
          // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)

          //1. list info for a student
          prettyPrint(c.getInfo("2222222222"));
          pause();

          //2. register student to unlimited course. Course CCC555 has unlimited capacity. Check that the student got registered.
          System.out.println(c.register("4444444444", "CCC555")); //✅
          //pause();

          //3. register the same student to the same course again and see that you get an error message
          System.out.println(c.register("4444444444", "CCC555")); //✅
          pause();

          //4. Unregister the student from the course, and then unregister again from the same course. Check that the student is no longer registered and the second unregistration gives an error response.
          System.out.println(c.unregister("4444444444", "CCC555")); //✅
          pause();
          System.out.println(c.unregister("4444444444", "CCC555")); //✅
          pause();

          //5. Register the student for a course that they don't have the prerequisites for, and check that an error is generated.
          System.out.println(c.register("6666666666", "CCC111")); //✅
          pause();

          //6. Unregister a student from a restricted course that they are registered to, and which has at least two students in the queue. Register again to the same course and check that the student gets the correct (last) position in the waiting list.
          //Course CCC333 is not overfull.
          System.out.println(c.unregister("5555555555", "CCC333")); //✅
          pause();
          System.out.println(c.register("5555555555", "CCC333")); //✅
          pause();

          //7. Unregister and re-register the same student for the same restricted course, and check that the student is first removed and then ends up in the same position as before (last).
          System.out.println(c.unregister("5555555555", "CCC333")); //✅
          pause();
          System.out.println(c.register("5555555555", "CCC333")); //✅
          pause();

          //8. Unregister a student from an overfull course, i.e. one with more students registered than there are places on the course (you need to set this situation up in the database directly). Check that no student was moved from the queue to being registered as a result.
          //The course CCC222 is overfull. No student in the waiting list will be moved to it.
          System.out.println(c.unregister("5555555555", "CCC222")); //✅
          pause();

          //9. Unregister with the SQL injection you introduced, causing all (or almost all?) registrations to disappear.
          //code for SQL injection...The condition 'a'='a' will always be true, hence all rows will be affected by the DELETE statement.
          //SQL injection. The vulnerability that allows us to do this SQL injection is the use of statement instead of preparedStatement in the unregister function.
          System.out.println(c.unregister("4444444444", "CCC555' OR 'a'='a"));
      
      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
   
   
   
   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}