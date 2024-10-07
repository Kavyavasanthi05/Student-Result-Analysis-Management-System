<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Results</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .container {
            display: flex;
            justify-content: space-between;
        }
        .table-container, .chart-container {
            flex: 1;
        }
        .table-container table {
            width: 100%;
            border-collapse: collapse;
        }
        .table-container th, .table-container td {
            border: 1px solid black;
            padding: 8px;
        }
        .chart-container canvas {
            width: 100%;
            max-width: 600px;
            height: 400px;
        }
    </style>
</head>
<body>
    <h1>Student Results</h1>

    <% 
    String url = "jdbc:mysql://localhost:3306/result";
    String user = "root";
    String password = ""; // Change this to your MySQL password

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    ResultSetMetaData metaData = null;
    int columnCount = 0;
    String selectedTable = request.getParameter("tableName");

    try {
        // Load MySQL driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish connection
        conn = DriverManager.getConnection(url, user, password);

        if (selectedTable == null || selectedTable.isEmpty()) {
            // Query to get all table names
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SHOW TABLES");
    %>
    <h2>Select Table</h2>
    <form method="get" action="">
        <select name="tableName">
            <% 
            while (rs.next()) {
                String tableName = rs.getString(1);
            %>
            <option value="<%= tableName %>"><%= tableName %></option>
            <% 
            }
            %>
        </select>
        <input type="submit" value="Show Data">
    </form>
    <% 
            return; // Exits the JSP if no table is selected
        } else {
            // Query to fetch data from the selected table
            stmt = conn.createStatement();
            String query = "SELECT * FROM " + selectedTable;
            rs = stmt.executeQuery(query);
            metaData = rs.getMetaData();
            columnCount = metaData.getColumnCount();
        }
    %>

    <h2>Student Data</h2>
    <table>
        <thead>
            <tr>
                <% 
                // Output table headers
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<th>" + metaData.getColumnName(i) + "</th>");
                }
                %>
            </tr>
        </thead>
        <tbody>
            <% 
            // Output table rows
            if (rs != null) {
                while (rs.next()) {
                    out.println("<tr>");
                    for (int i = 1; i <= columnCount; i++) {
                        out.println("<td>" + rs.getString(i) + "</td>");
                    }
                    out.println("</tr>");
                }
            }
            %>
        </tbody>
    </table>

    <h2>Statistics</h2>
    <div class="container">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Statistic</th>
                        <th>Value</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    // Initialize variables for statistics
                    int totalStudents = 0;
                    int passedStudents = 0;
                    int firstClassStudents = 0;
                    int secondClassStudents = 0;
                    int thirdClassStudents = 0;
                    int failedStudents = 0;
                    double classAverage = 0.0;

                    // Define queries
                    String[] statsLabels = {
                        "No. of Students Appeared",
                        "No. of Students Passed",
                        "No. of Students with First Class",
                        "No. of Students with Second Class",
                        "No. of Students with Third Class",
                        "No. of Students Failed",
                        "Class Average Mark"
                    };

                    String[] statsQueries = {
                        "SELECT COUNT(*) AS total FROM " + selectedTable,
                        "SELECT COUNT(*) AS total FROM " + selectedTable + " WHERE RES = 'P'",
                        "SELECT COUNT(*) AS total FROM " + selectedTable + " WHERE SGPA >= 6.0 AND SGPA <= 10.0",
                        "SELECT COUNT(*) AS total FROM " + selectedTable + " WHERE SGPA >= 5.0 AND SGPA < 6.0",
                        "SELECT COUNT(*) AS total FROM " + selectedTable + " WHERE SGPA >= 3.0 AND SGPA < 5.0",
                        "SELECT COUNT(*) AS total FROM " + selectedTable + " WHERE RES = 'F'",
                        "SELECT AVG(SGPA) AS average FROM " + selectedTable
                    };

                    for (int i = 0; i < statsLabels.length; i++) {
                        try {
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery(statsQueries[i]);
                            if (rs.next()) {
                                if (i == statsLabels.length - 1) {
                                    classAverage = rs.getDouble("average");
                                    out.println("<tr><td>" + statsLabels[i] + "</td><td>" + String.format("%.2f", classAverage) + "</td></tr>");
                                } else {
                                    int count = rs.getInt("total");
                                    switch (i) {
                                        case 0: totalStudents = count; break;
                                        case 1: passedStudents = count; break;
                                        case 2: firstClassStudents = count; break;
                                        case 3: secondClassStudents = count; break;
                                        case 4: thirdClassStudents = count; break;
                                        case 5: failedStudents = count; break;
                                    }
                                    out.println("<tr><td>" + statsLabels[i] + "</td><td>" + count + "</td></tr>");
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<tr><td>" + statsLabels[i] + "</td><td>Database error: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
        
        <div class="chart-container">
            <canvas id="studentResultsChart"></canvas>
            <script>
                var ctx = document.getElementById('studentResultsChart').getContext('2d');
                var studentResultsChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['Total Students', 'Passed Students', 'First Class', 'Second Class', 'Third Class', 'Failed Students'],
                        datasets: [{
                            label: 'Number of Students',
                            data: [
                                <%= totalStudents %>,
                                <%= passedStudents %>,
                                <%= firstClassStudents %>,
                                <%= secondClassStudents %>,
                                <%= thirdClassStudents %>,
                                <%= failedStudents %>
                            ],
                            backgroundColor: [
                                'rgba(75, 192, 192, 0.2)',
                                'rgba(14, 63, 95, 0.2)',
                                'rgba(255, 206, 86, 0.2)',
                                'rgba(75, 192, 192, 0.2)',
                                'rgba(153, 102, 255, 0.2)',
                                'rgba(255, 99, 132, 0.2)'
                            ],
                            borderColor: [
                                'rgba(75, 192, 192, 1)',
                                'rgba(14, 62, 95, 1)',
                                'rgba(255, 206, 86, 1)',
                                'rgba(75, 192, 192, 1)',
                                'rgba(153, 102, 255, 1)',
                                'rgba(255, 99, 132, 1)'
                            ],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        plugins: {
                            legend: {
                                display: false // This hides the legend
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        }
                    }
                });
            </script>
        </div>
    </div>

    <% 
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        // Clean up resources
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            out.println("<p>Error closing resources: " + e.getMessage() + "</p>");
        }
    }
    %>
</body>
</html>
