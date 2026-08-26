import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case.dart';

class CaseCard extends StatelessWidget {
  final Case caseData;
  final VoidCallback onReview;

  const CaseCard({
    Key? key,
    required this.caseData,
    required this.onReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [

            Expanded(
              child: Row(
                children: [

                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: caseData.imageUrl != null && caseData.imageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              caseData.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Color(0xFF4CAF50),
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Color(0xFF4CAF50),
                            size: 24,
                          ),
                  ),
                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          caseData.personName,
                          style: GoogleFonts.questrial(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        SizedBox(height: 4),

                        Text(
                          caseData.impact,
                          style: GoogleFonts.questrial(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),

                        InkWell(
                          onTap: () {
                            if (caseData.sourceUrl.isNotEmpty) {
                              onReview();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No link available for this case.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Review Case',
                                style: GoogleFonts.questrial(
                                  fontSize: 12,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.open_in_new,
                                size: 14,
                                color: Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Text(
                  caseData.climateEvent,
                  style: GoogleFonts.questrial(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8),

                Text(
                  caseData.location,
                  style: GoogleFonts.questrial(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}