package Results;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/subjectAnalysis")
public class Subjectwise extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Database connection parameters
        String url = "jdbc:mysql://localhost:3306/result";
        String username = "root";
        String password = " ";

        // SQL query to retrieve the data
        String query = "SELECT ENG_IG, ENGC, ENGGP, M_IG, M_IC, M_IGP, pass FROM 1_1";

        // Data structures to hold analysis results
        int engPassCount = 0, engFailCount = 0, engAbove7Count = 0;
        int mPassCount = 0, mFailCount = 0, mAbove7Count = 0;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, username, password);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
                // Retrieve the grade points and pass status
                int engGP = rs.getInt("ENGGP");
                int mGP = rs.getInt("M_IGP");
                boolean pass = rs.getBoolean("pass");

                // English subject analysis
                if (engGP >= 7) {
                    engAbove7Count++;
                }
                if (pass) {
                    engPassCount++;
                } else {
                    engFailCount++;
                }

                // Mathematics subject analysis
                if (mGP >= 7) {
                    mAbove7Count++;
                }
                if (pass) {
                    mPassCount++;
                } else {
                    mFailCount++;
                }
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Set results as request attributes
        request.setAttribute("engPassCount", engPassCount);
        request.setAttribute("engFailCount", engFailCount);
        request.setAttribute("engAbove7Count", engAbove7Count);
        request.setAttribute("mPassCount", mPassCount);
        request.setAttribute("mFailCount", mFailCount);
        request.setAttribute("mAbove7Count", mAbove7Count);

        // Forward to JSP
        request.getRequestDispatcher("/subjectwise.jsp").forward(request, response);
    }
}
