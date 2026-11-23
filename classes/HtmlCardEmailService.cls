public class HtmlCardEmailService {
    public static void sendEmailWithHtmlCards(String recipientEmail) {
        // Generate HTML content
        String htmlContent = generateHtmlCards();

        // Create the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { recipientEmail });
        mail.setSubject('HTML Cards with Account Information');
        mail.setHtmlBody(htmlContent);

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static String generateHtmlCards() {
        List<Account> accounts = [SELECT Id, Name, Description, Website FROM Account LIMIT 10];
        String htmlContent = '<table style="width: 100%;">'; // Table container for cards

        for (Integer i = 0; i < accounts.size(); i += 2) {
            htmlContent += '<tr>'; // Start a new row

            // First column
            if (i < accounts.size()) {
                Account acc = accounts[i];
                htmlContent += '<td style="width: 50%; padding: 10px;">';
                htmlContent += '<div class="card" style="border: 1px solid #ccc; border-radius: 5px; padding: 10px; box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);">';
                htmlContent += '<h3>' + acc.Name + '</h3>';
                htmlContent += '<p>' + (acc.Description != null ? acc.Description : 'No description available') + '</p>';
                htmlContent += '<a href="' + (acc.Website != null ? acc.Website : '#') + '" target="_blank">' + (acc.Website != null ? acc.Website : 'No link available') + '</a>';
                htmlContent += '</div>';
                htmlContent += '</td>';
            }

            // Second column
            if (i + 1 < accounts.size()) {
                Account acc = accounts[i + 1];
                htmlContent += '<td style="width: 50%; padding: 10px;">';
                htmlContent += '<div class="card" style="border: 1px solid #ccc; border-radius: 5px; padding: 10px; box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);">';
                htmlContent += '<h3>' + acc.Name + '</h3>';
                htmlContent += '<p>' + (acc.Description != null ? acc.Description : 'No description available') + '</p>';
                htmlContent += '<a href="' + (acc.Website != null ? acc.Website : '#') + '" target="_blank">' + (acc.Website != null ? acc.Website : 'No link available') + '</a>';
                htmlContent += '</div>';
                htmlContent += '</td>';
            } else {
                // If there is no second column, add an empty cell to maintain the structure
                htmlContent += '<td style="width: 50%; padding: 10px;"></td>';
            }

            htmlContent += '</tr>'; // Close the row
        }

        htmlContent += '</table>'; // Close table container
        return htmlContent;
    }
}