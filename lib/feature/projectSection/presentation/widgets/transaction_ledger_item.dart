import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:site_board/feature/projectSection/domain/entities/material_transaction.dart';

class TransactionLedgerItem extends StatelessWidget {
  final MaterialTransaction transaction;
  final bool showFinancials;

  const TransactionLedgerItem({
    super.key,
    required this.transaction,
    required this.showFinancials,
  });

  @override
  Widget build(BuildContext context) {
    final isIN = transaction.type == TransactionType.IN;
    final color = isIN ? Colors.green : Colors.red;
    final qtyPrefix = isIN ? '+' : '-';

    // Formatters
    final dateStr = DateFormat('MMM dd, hh:mm a').format(transaction.timestamp);
    final currencyFmt = NumberFormat.simpleCurrency();

    // Anomaly Check (Time-based: Before 6 AM or After 8 PM)
    final hour = transaction.timestamp.hour;
    final isTimeAnomaly = hour < 6 || hour >= 20;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation:
          0, // Flat design preferred for ledgers? Or keep slightly elevated.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon / Indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIN ? Icons.download : Icons.upload,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Material Name & Qty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              transaction.materialName ?? 'Unknown Material',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "$qtyPrefix${_formatQty(transaction.quantityChange.abs())}",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Date & Actor
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.actorName ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isTimeAnomaly) ...[
                            const SizedBox(width: 8),
                            Tooltip(
                              message: "Unusual Time",
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 10,
                                      color: Colors.amber.shade900,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "Odd Time",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 3. Financial Expansion
            if (showFinancials && isIN) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Unit Cost: ${transaction.unitPrice != null ? currencyFmt.format(transaction.unitPrice) : '--'}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  Text(
                    "Total: ${transaction.unitPrice != null ? currencyFmt.format(transaction.quantityChange * transaction.unitPrice!) : '--'}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatQty(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }
}
