// lib/domaine/facture/facture_pdf_service.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FacturePdfService {
  static Future<Uint8List> generatePdf(VenteModel vente) async {
    final pdf = pw.Document();

    if (vente.details.isEmpty) {
      throw Exception("Aucun détail de vente disponible pour la facture");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(vente),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                _buildInvoiceInfo(vente),
                pw.SizedBox(height: 30),
                _buildProductsTable(vente),
                pw.SizedBox(height: 20),
                _buildTotalSection(vente),
                pw.SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(VenteModel vente) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Bazar Pharma',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.Text(
              'Votre pharmacie de confiance',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tel: +243 812 345 678',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
            ),
            pw.Text(
              'Email: contact@pharmacie.com',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.black,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            'FACTURE',
            style: const pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(VenteModel vente) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final dateStr = vente.createdAt != null
        ? dateFormat.format(vente.createdAt!)
        : 'Date non disponible';

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'N° Facture: ${vente.factureNumero}',
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Icon(
                    pw.IconData(0xe192),
                    size: 16,
                    color: PdfColors.grey600,
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    'Date: $dateStr',
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Client: ${vente.clientName}',
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                children: [
                  pw.Icon(
                    pw.IconData(0xe7fd),
                    size: 16,
                    color: PdfColors.grey600,
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    '${vente.details.length} article${vente.details.length > 1 ? 's' : ''}',
                    style: const pw.TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProductsTable(VenteModel vente) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails des produits',
          style: const pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder(
            top: pw.BorderSide(color: PdfColors.blue700, width: 2),
            bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
            horizontalInside: pw.BorderSide(
              color: PdfColors.grey300,
              width: 0.5,
            ),
          ),
          columnWidths: {
            0: pw.FlexColumnWidth(5),
            1: pw.FlexColumnWidth(1.5),
            2: pw.FlexColumnWidth(2.5),
            3: pw.FlexColumnWidth(2.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'PRODUIT',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blue700,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'QTÉ',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blue700,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'PRIX UNITAIRE',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blue700,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'TOTAL',
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColors.blue700,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            ...vente.details.map((detail) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          detail.produit.name,
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        if (detail.produit.category.isNotEmpty)
                          pw.Text(
                            'Cat: ${detail.produit.category}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Container(
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        detail.quantite.toString(),
                        style: const pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      '${detail.price.toStringAsFixed(0)} FC',
                      style: const pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      '${(detail.price * detail.quantite).toStringAsFixed(0)} FC',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTotalSection(VenteModel vente) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.blue200, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Sous-total:',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
                pw.Text(
                  '${vente.total.toStringAsFixed(0)} FC',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL À PAYER: ',
                  style: const pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.Text(
                  '${vente.total.toStringAsFixed(0)} FC',
                  style: const pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Toutes taxes comprises',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Merci de votre confiance !',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.Text(
                  'Nous vous souhaitons une agréable journée.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey400),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Zarba Pharma',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'www.pharmacie.com',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey400),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ✅ NOUVELLE MÉTHODE : Impression avec dialogue d'aperçu
  static Future<void> imprimerAvecApercu(
    BuildContext context,
    VenteModel vente,
  ) async {
    try {
      print('📄 Génération de la facture avec aperçu pour ${vente.clientName}');

      final pdfBytes = await generatePdf(vente);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      print('❌ Erreur impression: $e');
      rethrow;
    }
  }

  // ✅ NOUVELLE MÉTHODE : Impression directe (téléchargement + partage)
  static Future<void> imprimer(BuildContext context, VenteModel vente) async {
    try {
      print('📄 Génération de la facture pour ${vente.clientName}');

      final pdfBytes = await generatePdf(vente);

      // Sauvegarder temporairement le PDF
      final tempDir = await getTemporaryDirectory();
      final fileName = 'Facture_${vente.factureNumero}.pdf';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        // Si l'ouverture échoue, proposer le partage
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'Facture ${vente.factureNumero} - ${vente.clientName}\nTotal: ${vente.total.toStringAsFixed(0)} FC',
          subject: 'Facture ${vente.factureNumero}',
        );
      }
    } catch (e) {
      print('❌ Erreur impression: $e');
      rethrow;
    }
  }

  // ✅ Méthode pour imprimer avec dialogue de chargement (à utiliser dans VentePage)
  static Future<void> imprimerAvecDialogue(
    BuildContext context,
    VenteModel vente,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdfBytes = await generatePdf(vente);

      if (context.mounted) {
        Navigator.pop(context);
      }

      // Sauvegarder et ouvrir le PDF
      final tempDir = await getTemporaryDirectory();
      final fileName = 'Facture_${vente.factureNumero}.pdf';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Ouvrir le PDF
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done && context.mounted) {
        // Si l'ouverture échoue, proposer le partage
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'Facture ${vente.factureNumero} - ${vente.clientName}\nTotal: ${vente.total.toStringAsFixed(0)} FC',
          subject: 'Facture ${vente.factureNumero}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode de sauvegarde (inchangée)
  static Future<String> sauvegarderPdf(VenteModel vente) async {
    try {
      final pdfBytes = await generatePdf(vente);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Facture_${vente.factureNumero}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      print('✅ PDF sauvegardé: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
      rethrow;
    }
  }

  // Méthode de partage (inchangée)
  static Future<void> partagerPdf(VenteModel vente) async {
    try {
      final filePath = await sauvegarderPdf(vente);

      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'Facture ${vente.factureNumero} - ${vente.clientName}\nTotal: ${vente.total.toStringAsFixed(0)} FC',
        subject: 'Facture ${vente.factureNumero}',
      );

      print('✅ PDF partagé avec succès');
    } catch (e) {
      print('❌ Erreur partage: $e');
      rethrow;
    }
  }
}
