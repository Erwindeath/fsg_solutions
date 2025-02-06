// ignore_for_file: unused_local_variable

import 'package:flutter/services.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/clase_data_inicial.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfCreator {
  List<ReportItem> report = [];
  Future<Uint8List> crearPdf(
    String titulo,
    String subtitulo,
    String contenido, {
    List<SignatureEntity> personal = const [],
    List<SignatureEntity> equipo = const [],
    List<ReportItem> reporte = const [],
    String firmaGrupo = "",
    String firmaDep = "",
    String textoFinal = "",
    String textoFin = "",
    double valorTotal = 0.00,
  }) async {
    try {
      report = [...reporte];
      final pdfData = await _generatePdf(contenido, titulo, subtitulo, firmaGrupo, firmaDep, personal, equipo, textoFinal, textoFin, valorTotal);
      await Printing.layoutPdf(
          onLayout: (format) async {
            return pdfData;
          },
          dynamicLayout: true,
          usePrinterSettings: true);

      return pdfData;
    } catch (e) {
      // print("Error al crear el PDF: $e");
      return Uint8List(0); // Retornar false si hay algún error
    }
  }

  String toCapitalCase(String text) {
    if (text == "" || text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _drawHeader(PdfPage page, String titulo, String subtitulo, double marginLeft, double marginRight) async {
    final PdfFont headerFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      8,
      style: PdfFontStyle.italic,
    );
    titulo = toCapitalCase(titulo);
    final PdfFont subHeaderFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      8,
    );

    final double totalWidth = page.getClientSize().width;
    final double contentWidth = totalWidth - marginLeft - marginRight - 80;
    final double xPosition = marginLeft + 5; // Usamos marginLeft como posición inicial
    const double yPosition = 0;

    // Título
    page.graphics.drawString(
      titulo,
      headerFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(xPosition, yPosition, contentWidth, 0),
      format: PdfStringFormat(alignment: PdfTextAlignment.left), // Cambio a alineación izquierda.
    );

    // Línea divisoria
    final double lineYPosition = yPosition + headerFont.height + 5;
    page.graphics.drawLine(
      PdfPen(PdfColor(188, 41, 41)),
      Offset(xPosition, lineYPosition),
      Offset(xPosition + contentWidth - 60, lineYPosition),
    );

    // Subtítulo
    final double subTitleYPosition = lineYPosition + 5; // Ajustado para que el subtítulo esté después de la línea.
    page.graphics.drawString(
      subtitulo,
      subHeaderFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(xPosition, subTitleYPosition, contentWidth, 0),
      format: PdfStringFormat(alignment: PdfTextAlignment.left), // Cambio a alineación izquierda.
    );
  }

  Future<Uint8List> _readImageData(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> _generatePdf(
    String contenido,
    String titulo,
    String subtitulo,
    String firmaGrupo,
    String firmaDep,
    List<SignatureEntity> personal,
    List<SignatureEntity> equipo,
    String textoFinal,
    String textoFin,
    double totalInv,
  ) async {
    final PdfDocument document = PdfDocument();

    const double marginLeft = (2.0 * 28.3465) - 35;
    const double marginTop = 2.0 * 28.3465 - 5;
    const double marginRight = 2.0 * 28.3465 - 20;
    document.pageSettings.margins.left = marginLeft;
    document.pageSettings.margins.top = marginTop;
    document.pageSettings.margins.right = marginRight;

    var page = document.pages.add();

    final PdfBitmap image = PdfBitmap(await _readImageData('assets/images/logoFSG.png'));
    page.graphics.drawImage(image, Rect.fromLTWH(page.getClientSize().width - 90, 0, 80, 20));

    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.timesRoman, 12, style: PdfFontStyle.bold);
    final PdfFont fontSubtitulo = PdfStandardFont(PdfFontFamily.timesRoman, 12, style: PdfFontStyle.italic);
    final PdfFont fontContenido = PdfStandardFont(PdfFontFamily.timesRoman, 10);

    // Área disponible en el ancho de la página teniendo en cuenta los márgenes
    double contentWidth = 595.28 - marginLeft - marginRight + 5;
    //print(contentWidth);
    double xPosition = marginLeft;
    double yPosition = marginTop;
    // Título y subtítulo
    page.graphics.drawString(titulo, fontTitulo,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(xPosition, yPosition, contentWidth, 0),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    yPosition += 15;
    page.graphics.drawString(subtitulo, fontSubtitulo,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(xPosition, yPosition, contentWidth, 0),
        format: PdfStringFormat(alignment: PdfTextAlignment.center));
    yPosition += 15;

    // Crear un PdfGrid
    final PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 10, top: 10, right: 10, bottom: 10));
    grid.columns.add(count: 1);

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = contenido;
    row.cells[0].style.font = fontContenido;
    row.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.justify, lineSpacing: 2.5, wordWrap: PdfWordWrapType.word);
    row.cells[0].style.borders.all = PdfPen(PdfColor(255, 255, 255), width: 0);

    // Dibuja el contenido en la página
    PdfLayoutResult? result = grid.draw(page: page, bounds: Rect.fromLTWH(xPosition, yPosition, contentWidth, 0));
    yPosition += result!.bounds.height + 10;

    // Sección de firmas
    final PdfGrid signatureGrid = PdfGrid();
    signatureGrid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 10, top: 10, right: 10, bottom: 10));
    signatureGrid.columns.add(count: 3);
// Sección de firmas
    const double footerSpace = 30;
    //const double signatureSectionSpace = 100; // Esto depende de cuánto espacio estimas que necesitas.
    int numberOfSignatures = personal.length + equipo.length; // asumiendo que 'personal' y 'equipo' son las listas de firmas
    const double spacePerSignature = 20; // Ajusta esto al espacio vertical que necesita cada firma
    const int signaturesPerRow = 3; // Si las firmas están dispuestas en filas de a tres
    const double spaceBetweenRows = 10; // Espacio entre filas de firmas

    int numberOfRows = (numberOfSignatures / signaturesPerRow).ceil(); // Redondear hacia arriba para obtener el número de filas
    double totalSignatureSpace = numberOfRows * (spacePerSignature + spaceBetweenRows); // Espacio total requerido para las firmas

    double availableSpace = page.getClientSize().height - yPosition - footerSpace; // Restar el espacio del pie de página.

    if (availableSpace < totalSignatureSpace) {
      document.pages.add(); // Agregar una nueva página.
      page = document.pages[document.pages.count - 1]; // Cambiar a la nueva página.
      yPosition = marginTop; // Reiniciar yPosition al margen superior de la nueva página.
      //  availableSpace = page.getClientSize().height - footerSpace; // Calcular el nuevo espacio disponible.
    }

    addSignaturesSection(page, yPosition, firmaGrupo, equipo, marginLeft, marginRight, titulo, 1);
    yPosition += ((equipo.length / 3).ceil() * 60) + 10;

// Verifica si hay suficiente espacio disponible para la segunda sección
    int numberOfSignaturesSecondSection = personal.length;
    double spaceNeededForSecondSection = (numberOfSignaturesSecondSection / 3).ceil() * 60;
    availableSpace = page.getClientSize().height - yPosition - footerSpace;

    if (availableSpace < spaceNeededForSecondSection) {
      document.pages.add(); // Agrega una nueva página si es necesario
      page = document.pages[document.pages.count - 1];
      yPosition = marginTop; // Restablece yPosition al margen superior
    }

// Dibuja la segunda sección de firmas
    addSignaturesSection(page, yPosition, firmaDep, personal, marginLeft, marginRight, titulo, 2);
    if (report.isNotEmpty) {
      await _drawReportTable(document, marginLeft, yPosition, report, titulo, subtitulo, marginLeft, marginRight, textoFinal, textoFin, totalInv);
    }

    int totalPages = document.pages.count;

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      page = document.pages[pageIndex];
      _drawHeader(page, titulo, subtitulo, marginLeft, marginRight);
      // _drawFooter(page, pageIndex + 1, totalPages,document, marginLeft, marginRight);
    }
    if (report.isEmpty) {
      for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        page = document.pages[pageIndex];
        await _drawFooter(document.pages[pageIndex], pageIndex + 1, totalPages, document, marginLeft, marginRight);
      }
    }
    List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }

  Future<void> addSignaturesSection(PdfPage page, double yPosition, String title, List<SignatureEntity> entities, double marginLeft,
      double marginRight, String titulo, int valor) async {
    double xPosition = marginLeft + 10;
    double contentWidth = 595.28 - marginLeft - marginRight;

    final PdfFont fontFirma = PdfStandardFont(PdfFontFamily.timesRoman, 10);
    final PdfFont fontTitle = PdfStandardFont(PdfFontFamily.timesRoman, 11, style: PdfFontStyle.bold);

    // Dibuja el título
    final Size titleSize = fontTitle.measureString(title);
    page.graphics.drawString(title, fontTitle, brush: PdfBrushes.black, bounds: Rect.fromLTWH(xPosition, yPosition, 0, 0));
    yPosition += titleSize.height + 10;
    yPosition += 10;
    double signatureSpaceWidth = contentWidth / 3; // El ancho se divide por 3 ya que queremos 3 firmas por fila.
    double signatureLineWidth = signatureSpaceWidth * 0.75;

    double initialYPositionForTexts = yPosition + 10;

    for (int i = 0; i < entities.length; i++) {
      if (i != 0 && i % 3 == 0) {
        initialYPositionForTexts += 60;
      }

      double signatureStartX = xPosition + (i % 3) * signatureSpaceWidth;
      double signatureStartY = initialYPositionForTexts;

      // Dibuja la línea de firma.
      page.graphics.drawLine(
          PdfPen(PdfColor(0, 0, 0)), Offset(signatureStartX, signatureStartY), Offset(signatureStartX + signatureLineWidth, signatureStartY));

      // Dibuja el nombre.
      double textStartX = (signatureStartX + signatureLineWidth / 2) - 85;
      double textStartY = signatureStartY + 5; // Ajusta la posición vertical para el texto.
      page.graphics.drawString(entities[i].getSignatureName(), fontFirma,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(textStartX, textStartY, signatureSpaceWidth, 0),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));
      textStartY = textStartY + 10;

      // Dibuja la cédula.
      page.graphics.drawString(entities[i].getSignatureDetails(), fontFirma,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(textStartX, textStartY, signatureSpaceWidth, 0),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));
    }
  }

  Future<void> _drawFooter(PdfPage page, int pageIndex, int totalPages, PdfDocument document, double marginLeft, double marginRight) async {
    final PdfFont footerFont = PdfStandardFont(
      PdfFontFamily.timesRoman,
      8,
    );

    final double contentWidth = page.getClientSize().width - marginLeft - marginRight - 80;
    double xPosition = marginLeft + 10;
    double yPosition = page.getClientSize().height; // Aproximadamente 30 puntos del borde inferior.

    // Subtítulo
    final double subTitleYPosition = yPosition - footerFont.height - 5;
    page.graphics.drawString(
      "Farmacias San Gregorio",
      footerFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(xPosition, subTitleYPosition, contentWidth, 0),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    // Línea divisoria
    final double lineYPosition = subTitleYPosition - 5;
    page.graphics.drawLine(
      PdfPen(PdfColor(188, 41, 41)),
      Offset(xPosition, lineYPosition),
      Offset(xPosition + contentWidth - 60, lineYPosition),
    );

    // Título
    final double titleYPosition = lineYPosition - footerFont.height - 5;
    page.graphics.drawString(
      "Jefatura de Inventario",
      footerFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(xPosition, titleYPosition, contentWidth, 0),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    // Número de página
    final String pageNumberString = 'Pág. $pageIndex de $totalPages';
    page.graphics.drawString(
      pageNumberString,
      footerFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(xPosition + 90, yPosition - 2 * footerFont.height, contentWidth, 0),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
  }

  double marginTop = 2.0 * 28.3465;

  Future<void> _drawReportTable(PdfDocument document, double xPosition, double top, List<ReportItem> reporte, String titulo, String subtitulo,
      double marginLeft, double marginRight, String textoFinal, String textFin, double totalInv) async {
    double totalValue = reporte[0].totalInventariar;
    PdfLayoutResult? result;
    const double headerHeight = 32;

    const int rowMaximas = 38; // Ajusta este valor según tus necesidades.
    int currentRowIndex = 0;
    PdfStringFormat rightAlignment = PdfStringFormat(alignment: PdfTextAlignment.right);

    while (currentRowIndex < reporte.length) {
      var page = document.pages.add();
      await _drawHeader(page, titulo, subtitulo, marginLeft, marginRight);

      final PdfGrid reportGrid = PdfGrid();

      // Configurar el estilo de la celda
      reportGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 1, top: 1, right: 1, bottom: 1),
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8),
      );

      // Agregar columnas a la tabla de informe
      reportGrid.columns.add(count: 7);

      // Agregar encabezados de columna
      reportGrid.headers.add(1);
      reportGrid.headers[0].cells[0].value = 'Lab';
      reportGrid.headers[0].cells[1].value = 'Descripción';
      reportGrid.headers[0].cells[2].value = 'Cant. Cajas';
      reportGrid.headers[0].cells[3].value = 'Cant. Fracciones';
      reportGrid.headers[0].cells[4].value = 'P. Caja';
      reportGrid.headers[0].cells[5].value = 'P. Fracción';
      reportGrid.headers[0].cells[6].value = 'Total';
      reportGrid.columns[0].width = 40;
      reportGrid.columns[1].width = 200;
      reportGrid.columns[2].width = 50;
      reportGrid.columns[3].width = 50;
      reportGrid.columns[4].width = 50;
      reportGrid.columns[5].width = 50;
      reportGrid.columns[6].width = 50;
      reportGrid.headers[0].cells[2].stringFormat = rightAlignment;
      reportGrid.headers[0].cells[3].stringFormat = rightAlignment;
      reportGrid.headers[0].cells[4].stringFormat = rightAlignment;
      reportGrid.headers[0].cells[5].stringFormat = rightAlignment;
      reportGrid.headers[0].cells[6].stringFormat = rightAlignment;

      // Agregar filas de datos
      for (int i = 0; i < rowMaximas && currentRowIndex < reporte.length; i++, currentRowIndex++) {
        var item = reporte[currentRowIndex];
        PdfGridRow row = reportGrid.rows.add();
        row.cells[0].value = item.laboratorio;
        row.cells[1].value = item.descripcion;
        row.cells[2].value = item.cantidadCajas.toString();
        row.cells[3].value = item.cantidadFracciones.toString();
        row.cells[4].value = item.precioCaja.toString();
        row.cells[5].value = item.precioFraccion.toString();
        row.cells[6].value = item.total.toString();
        row.cells[2].stringFormat = rightAlignment;
        row.cells[3].stringFormat = rightAlignment;
        row.cells[4].stringFormat = rightAlignment;
        row.cells[5].stringFormat = rightAlignment;
        row.cells[6].stringFormat = rightAlignment;
      }

      // Dibuja la tabla en la página
      result = reportGrid.draw(page: page, bounds: Rect.fromLTWH(xPosition + 10, headerHeight + 15, 546.894, 0));
    }
    double yPosition = result!.bounds.height + 10;
    await calculoTotal(totalValue, document, xPosition, yPosition, 0, rightAlignment, textoFinal, textFin, totalInv);
    int totalPages = document.pages.count;

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      _drawFooter(document.pages[pageIndex], pageIndex + 1, totalPages, document, marginLeft, marginRight);
    }
  }

  Future<void> calculoTotal(double total, PdfDocument document, double xPosition, double yPosition, double contentWidth, PdfStringFormat formato,
      String textoFinal, String textFin, double totalInv) async {
    final PdfGrid reportGrid = PdfGrid();
    //  print(total);//
    // Configurar el estilo de la celda
    //print(document.pages.count);
    reportGrid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 1, top: 1, right: 1, bottom: 1),
      font: PdfStandardFont(PdfFontFamily.timesRoman, 8),
    );
    final PdfFont boldFont = PdfStandardFont(PdfFontFamily.timesRoman, 8, style: PdfFontStyle.bold);

    // Agregar columnas a la tabla de informe
    reportGrid.columns.add(count: 2);
    reportGrid.headers.add(2);
    reportGrid.headers[0].cells[0].value = textoFinal;
    reportGrid.headers[0].cells[1].value = '\$${total.toStringAsFixed(2)}';
    reportGrid.headers[0].cells[0].style.font = boldFont; // Aplicar la fuente en negrita a la celda "Total"

    reportGrid.headers[1].cells[0].value = textFin;
    reportGrid.headers[1].cells[1].value = '\$${totalInv.toStringAsFixed(2)}';
    reportGrid.headers[1].cells[0].style.font = boldFont;

    reportGrid.headers[0].cells[1].stringFormat = formato;
    reportGrid.headers[1].cells[1].stringFormat = formato;
    PdfLayoutResult? result =
        reportGrid.draw(page: document.pages[document.pages.count - 1], bounds: Rect.fromLTWH(xPosition + 10, yPosition + 50, 520.894, 0));
    //yPosition += result!.bounds.height + 10;
  }
}
