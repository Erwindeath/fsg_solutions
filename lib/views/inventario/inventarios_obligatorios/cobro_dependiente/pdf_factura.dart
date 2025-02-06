// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fsg_solutions/views/inventario/inventarios_obligatorios/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:barcode_image/barcode_image.dart';

class PdfCreator {
  Future<bool> crearPdfFactura(List<Dato> datosFacturaList) async {
    try {
      final PdfDocument document = PdfDocument();

      for (var datosFactura in datosFacturaList) {
        // Aquí no es necesario crear un nuevo PdfDocument, simplemente genera los datos de la página y añade la página al documento.
        await _generatePdf(document, datosFactura);
      }

      final List<int> pdfData = await document.save();
      await Printing.layoutPdf(
          onLayout: (format) async {
            return Uint8List.fromList(pdfData);
          },
          dynamicLayout: true,
          usePrinterSettings: true);

      document.dispose();
      return true;
    } catch (e) {
      // print("Error al crear el PDF: $e");
      return false; // Retornar false si hay algún error
    }
  }

  Future<void> _generatePdf(PdfDocument document, Dato datosFactura) async {
    const double marginLeft = (2.0 * 28.3465) - 35;
    const double marginTop = 2.0 * 28.3465 - 5;
    const double marginRight = 2.0 * 28.3465 - 20;
    // final PdfDocument document = PdfDocument();
    //const double contentWidth = 595.28 - 2 * pageMargin;  // Ancho de página menos márgenes

    var page = document.pages.add();

    // Define el tamaño de la imagen
    const double imageWidth = 194.0;
    const double imageHeight = 38.5;
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final PdfFont fontSubTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    // Dibuja el logo en la parte superior izquierda
    final PdfBitmap image = PdfBitmap(await _readImageData('assets/images/logoFSG.png'));
    page.graphics.drawImage(image, const Rect.fromLTWH(0, marginTop - 5, imageWidth, imageHeight));

    // Define la posición inicial para la tabla debajo del logo

    double yPosition = marginTop; // Da espacio debajo del logo

    const double dataTableHeight = 210.0;
    // Crea una grilla para la descripción de la empresa
    /***************************TABLA PARA DETALLE EMPRESA************************************* */
    PdfGrid leftTable = _createLeftTable(datosFactura, fontTitulo, fontSubTitulo);
    PdfLayoutResult? result = leftTable.draw(page: page, bounds: Rect.fromLTWH(0, yPosition + 55, dataTableHeight, 0));
    yPosition += result!.bounds.height + 10;
    /**************************************************************** */
    /***************************TABLA PARA DETALLE FACTURA************************************* */
    PdfGrid rightTable = await _createRightTable(datosFactura, fontTitulo, fontSubTitulo);
    // Dibuja el contenido en la página
    PdfLayoutResult? result2 = rightTable.draw(page: page, bounds: const Rect.fromLTWH(250, 0, dataTableHeight + 360, 0));
    yPosition += result2!.bounds.height + 10;
    double desiredWidth = dataTableHeight + 50; // ajusta esto según tus necesidades

    // Dibuja un rectángulo alrededor de la tabla
    Rect tableBounds = result2.bounds;
    Rect adjustedBounds = Rect.fromLTWH(tableBounds.left, tableBounds.top, desiredWidth, tableBounds.height);

    page.graphics.drawRectangle(bounds: adjustedBounds, pen: PdfPens.black);
    /***************************TABLA DETALLE PERSONA************************************* */
    PdfGrid bottomTable = _createBottomTable(datosFactura, fontSubTitulo);
    double newTableWidth = 595.28 - marginLeft - marginRight;
    PdfLayoutResult? result3 = bottomTable.draw(page: page, bounds: Rect.fromLTWH(0, yPosition - 180, newTableWidth - 24, 0));
    yPosition += result3!.bounds.height + 10;
    /**************************************************************** */
    /***************************TABLA DETALLE PERSONA************************************* */

    PdfGrid productTable = await _createProductTable(datosFactura.details);

    List<Detail> productoslo = datosFactura.details;

    PdfLayoutResult? result4 = productTable.draw(page: page, bounds: Rect.fromLTWH(0, yPosition - 180, newTableWidth - 24, 0));
    PdfPage currentPage = result4!.page;
    yPosition = result4.bounds.bottom + 10;

    if (yPosition > (currentPage.getClientSize().height - marginTop) || (productoslo.length >= 10 && productoslo.length <= 22)) {
      currentPage = document.pages.add();
      yPosition = marginTop; // Resetea yPos para la nueva página
    }
    //double yPos += result4.bounds.height + 10;  // Actualizar yPosition después de la tabla de productos

    // Verifica si es necesario añadir una nueva página
    /* if (nextYPosition > (page.getClientSize().height - marginTop)) {
      page = document.pages.add();
      yPosition = marginTop; // Resetea yPos para la nueva página
    }*/
    // print(nextYPosition);
    /******************************Tabla Totales********************************** */
    PdfGrid totalTable = _createTotalTable(datosFactura);
    totalTable.draw(page: currentPage, bounds: Rect.fromLTWH(250, yPosition, newTableWidth - 24, 0));
    //yPosition = result5!.bounds.bottom + 10;
    /******************************Info adicional********************************** */
    PdfGrid infoTable = _createInfoAdicionalTable(datosFactura);
    PdfLayoutResult? result6 = infoTable.draw(page: currentPage, bounds: Rect.fromLTWH(0, yPosition, dataTableHeight, 0));
    yPosition = result6!.bounds.bottom + 10;
    //yPosition += result5!.bounds.height + 10;
    /******************************Formas de pago********************************** */
    PdfGrid fPago = _createFormasPagoTable(datosFactura);
    PdfLayoutResult? result7 = fPago.draw(page: currentPage, bounds: Rect.fromLTWH(0, yPosition, dataTableHeight + 30, 0));
    yPosition = result7!.bounds.bottom + 30;
    /******************************DECLARACION********************************** */
    PdfGrid declaracionTable = _createDeclaracionTable();
    PdfLayoutResult? result8 = declaracionTable.draw(page: currentPage, bounds: Rect.fromLTWH(0, yPosition, newTableWidth - 24, 0));
    yPosition = result8!.bounds.bottom + 10;

    _createSignatureLine(currentPage, (newTableWidth - 31) / 2 - 100, yPosition + 50);

    /* List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);*/
  }

  PdfGrid _createLeftTable(Dato datosFactura, PdfFont fontTitulo, PdfFont fontSubTitulo) {
    final PdfGrid grid = PdfGrid();

    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.inside);
    grid.columns.add(count: 1);

    // Agrega una sola fila y establece el valor de la celda
    PdfGridRow descRow = grid.rows.add();

    descRow.cells[0].value = datosFactura.razonSocial;
    descRow.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);
    descRow.cells[0].style.borders.bottom = PdfPens.transparent;
    descRow.cells[0].style.font = fontTitulo;
    // Añadir una nueva fila para la tabla anidada
    PdfGridRow nestedTableRow = grid.rows.add();

    final PdfGrid nestedGrid = PdfGrid();
    nestedGrid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 0, right: 0, top: 0, bottom: 0));
    nestedGrid.columns.add(count: 2); // dos columnas para tu necesidad
    nestedGrid.columns[0].width = 50;

    PdfGridRow nestedRow1 = nestedGrid.rows.add();
    nestedRow1.cells[0].value = 'Dir. Matriz:';
    nestedRow1.cells[0].style.font = fontSubTitulo;

    nestedRow1.cells[1].value = datosFactura.dirMatriz;

    PdfGridRow nestedRow2 = nestedGrid.rows.add();
    nestedRow2.cells[0].value = 'Dir. Sucursal:';
    nestedRow2.cells[0].style.font = fontSubTitulo;
    nestedRow2.cells[1].value = 'AV 7 DE AGOSTO SN Y ROSA MOSQUERA';

    PdfGridRow nestedRow3 = nestedGrid.rows.add();
    nestedRow3.cells[0].value = 'Telefono:';
    nestedRow3.cells[0].style.font = fontSubTitulo;
    nestedRow3.cells[1].value = '593 (5) 244-1658';
    for (int rowIndex = 0; rowIndex < nestedGrid.rows.count; rowIndex++) {
      PdfGridRow row = nestedGrid.rows[rowIndex];
      for (int cellIndex = 0; cellIndex < row.cells.count; cellIndex++) {
        row.cells[cellIndex].style.borders.all = PdfPens.transparent;
      }
    }
    nestedTableRow.cells[0].value = nestedGrid;
    nestedTableRow.cells[0].style.borders.bottom = PdfPens.transparent;
    nestedTableRow.cells[0].style.borders.top = PdfPens.transparent;

    PdfGridRow descRowText5 = grid.rows.add();
    descRowText5.cells[0].value = 'Contribuyente Especial';
    descRowText5.cells[0].style.font = fontSubTitulo;
    descRowText5.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);
    descRowText5.cells[0].style.borders.top = PdfPens.transparent;
    descRowText5.cells[0].style.borders.bottom = PdfPens.transparent;
    PdfGridRow descRowText6 = grid.rows.add();
    descRowText6.cells[0].value = 'Resolución #220 del 26/03/2009';
    descRowText6.cells[0].style.font = fontSubTitulo;
    descRowText6.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);
    descRowText6.cells[0].style.borders.top = PdfPens.transparent;
    return grid;
  }

  Future<PdfGrid> _createRightTable(Dato datosFactura, PdfFont fontTitulo, PdfFont fontSubTitulo) async {
// Dibuja la imagen en la celda con el tamaño deseado
    String path = await imprimir(datosFactura.claveAcceso);

    final PdfBitmap image = PdfBitmap(await _readImageData2(path));
    /*var fontData = await rootBundle.load('fonts/free3of9.ttf');
    PdfFont customFont = await loadCustomFont(fontData.buffer.asUint8List());*/
    PdfGrid _createInnerCell(String boldText, String normalText) {
      final PdfGrid innerGrid = PdfGrid();
      innerGrid.columns.add(count: 2);
      innerGrid.columns[0].width = 115; // ajustar este valor según tus necesidades

      final PdfGridRow row = innerGrid.rows.add();
      row.cells[0].value = boldText;
      row.cells[0].style.font = fontTitulo; // Negrita para "Ambiente" y "Emisión"
      row.cells[1].value = normalText;
      row.cells[1].style.font = fontSubTitulo;

      for (int rowIndex = 0; rowIndex < innerGrid.rows.count; rowIndex++) {
        PdfGridRow row = innerGrid.rows[rowIndex];
        for (int cellIndex = 0; cellIndex < row.cells.count; cellIndex++) {
          row.cells[cellIndex].style.borders.all = PdfPens.transparent;
        }
      }

      return innerGrid;
    }

    final PdfGrid grid2 = PdfGrid();
    grid2.style = PdfGridStyle(cellPadding: PdfPaddings(left: 10, top: 5, right: 15, bottom: 5));
    grid2.columns.add(count: 1);

    // Agrega una sola fila y establece el valor de la celda
    PdfGridRow descRow2 = grid2.rows.add();
    descRow2.cells[0].value = 'RUC: ${datosFactura.ruc}';
    descRow2.cells[0].style.font = fontTitulo;
    descRow2.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow3 = grid2.rows.add();
    descRow3.cells[0].value = 'FACTURA';
    descRow3.cells[0].style.font = fontTitulo;
    descRow3.cells[0].style.borders.top = PdfPens.transparent;
    descRow3.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow4 = grid2.rows.add();
    descRow4.cells[0].value = 'No. ${datosFactura.documento}';
    descRow4.cells[0].style.font = fontSubTitulo;
    descRow4.cells[0].style.borders.top = PdfPens.transparent;
    descRow4.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow5 = grid2.rows.add();
    descRow5.cells[0].value = 'NÚMERO DE AUTORIZACIÓN:';
    descRow5.cells[0].style.font = fontSubTitulo;
    descRow5.cells[0].style.borders.top = PdfPens.transparent;
    descRow5.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow6 = grid2.rows.add();
    descRow6.cells[0].value = datosFactura.claveAcceso;
    descRow6.cells[0].style.borders.top = PdfPens.transparent;
    descRow6.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow7 = grid2.rows.add();
    descRow7.cells[0].value = _createInnerCell('Ambiente', 'PRODUCCIÓN');

    PdfGridRow descRow8 = grid2.rows.add();
    descRow8.cells[0].value = _createInnerCell('Emisión', 'NORMAL');

    PdfGridRow descRow9 = grid2.rows.add();
    descRow9.cells[0].value = 'CLAVE DE ACCESO';
    descRow9.cells[0].style.font = fontSubTitulo;
    descRow9.cells[0].style.borders.top = PdfPens.transparent;
    descRow9.cells[0].style.borders.bottom = PdfPens.transparent;

    PdfGridRow descRow10 = grid2.rows.add();
    descRow10.cells[0].value = image;
    // descRow10.cells[0].style.font = customFont;
    descRow10.cells[0].style.cellPadding = PdfPaddings(left: 10, top: 5, right: 70, bottom: 5);
    descRow10.cells[0].style.borders.top = PdfPens.transparent;
    descRow10.cells[0].style.borders.bottom = PdfPens.transparent;
    /* descRow10.cells[0].style.borders.left = PdfPens.transparent;
    descRow10.cells[0].style.borders.right = PdfPens.transparent;*/

    PdfGridRow descRow11 = grid2.rows.add();
    descRow11.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.left, wordWrap: PdfWordWrapType.word);
    descRow11.cells[0].value = datosFactura.claveAcceso;
    descRow11.cells[0].style.borders.top = PdfPens.transparent;
    for (int rowIndex = 0; rowIndex < grid2.rows.count; rowIndex++) {
      PdfGridRow row = grid2.rows[rowIndex];
      for (int cellIndex = 0; cellIndex < row.cells.count; cellIndex++) {
        row.cells[cellIndex].style.borders.all = PdfPens.transparent;
      }
    }
    return grid2;
  }

  PdfGrid _createBottomTable(Dato datosFactura, PdfFont fontSubTitulo) {
    final PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.overlap);

    grid.columns.add(count: 2);
    grid.columns[0].width = 320; // Ajusta este valor según tus necesidades
    grid.columns[1].width = 195; // Ajusta este valor según tus necesidades
    // First nested grid
    final PdfGrid nestedGrid1 = _createNestedGrid(
      [
        ['Razón Social:', datosFactura.nombreCliente],
        ['Dirección:', datosFactura.direccion],
        ['RUC / CI:', datosFactura.rucCliente],
      ],
      fontSubTitulo,
    );

    // Second nested grid
    final PdfGrid nestedGrid2 = _createNestedGrid(
      [
        ['Teléfono:', datosFactura.telefono],
        ['Fecha de Emisión:', datosFactura.fecha],
      ],
      fontSubTitulo,
    );

    // Add both nested grids to the main grid
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = nestedGrid1;
    row.cells[0].style.borders.right = PdfPens.transparent;
    row.cells[1].value = nestedGrid2;
    row.cells[1].style.borders.left = PdfPens.transparent;
    /*for (int cellIndex = 0; cellIndex < row.cells.count; cellIndex++) {
      row.cells[cellIndex].style.borders.bottom = PdfPens.transparent;
      row.cells[cellIndex].style.borders.top = PdfPens.transparent;
    }*/

    return grid;
  }

  PdfGrid _createNestedGrid(List<List<String>> data, PdfFont fontSubTitulo) {
    final PdfGrid nestedGrid = PdfGrid();
    nestedGrid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 0, right: 0, top: 0, bottom: 0),
    );
    nestedGrid.columns.add(count: 2);
    nestedGrid.columns[0].width = 85;
    nestedGrid.columns[1].width = 190;
    for (final List<String> rowData in data) {
      final PdfGridRow row = nestedGrid.rows.add();
      row.cells[0].value = rowData[0];
      row.cells[0].style.font = fontSubTitulo;
      row.cells[1].value = rowData[1];
      for (int cellIndex = 0; cellIndex < row.cells.count; cellIndex++) {
        row.cells[cellIndex].style.borders.all = PdfPens.transparent;
      }
    }

    return nestedGrid;
  }

  Future<PdfGrid> _createProductTable(List<Detail> productos) async {
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 7); // Para 'codPrincipal', 'descripcion', 'cantidad' y 'precio'.
    grid.headers.add(1);
    PdfColor headerBackgroundColor = PdfColor(211, 211, 211); // Esto representa un tono de gris.

    grid.headers[0].cells[0].value = 'Cod. Principal';
    grid.headers[0].cells[0].style.cellPadding = PdfPaddings(left: 5, top: 8, right: 0, bottom: 2);

    grid.headers[0].cells[1].value = 'Descripción';
    grid.headers[0].cells[1].style.cellPadding = PdfPaddings(left: 5, top: 8, right: 0, bottom: 2);

    grid.headers[0].cells[2].value = 'Cant';
    grid.headers[0].cells[2].style.cellPadding = PdfPaddings(left: 5, top: 6, right: 0, bottom: 2);

    grid.headers[0].cells[3].value = 'Cant. Unidad';
    grid.headers[0].cells[3].style.cellPadding = PdfPaddings(left: 5, top: 6, right: 0, bottom: 2);

    grid.headers[0].cells[4].value = 'Cant. Fracción';
    grid.headers[0].cells[4].style.cellPadding = PdfPaddings(left: 5, top: 6, right: 0, bottom: 2);

    grid.headers[0].cells[5].value = 'Precio uni';
    grid.headers[0].cells[5].style.cellPadding = PdfPaddings(left: 5, top: 8, right: 0, bottom: 2);

    grid.headers[0].cells[6].value = 'Total';
    grid.headers[0].cells[6].style.cellPadding = PdfPaddings(left: 5, top: 8, right: 0, bottom: 2);

    grid.columns[0].width = 60;
    grid.columns[1].width = 195;
    grid.columns[2].width = 50;
    grid.columns[3].width = 50;
    grid.columns[4].width = 50;
    grid.columns[5].width = 55;
    grid.columns[6].width = 55;
    for (int i = 0; i < grid.headers[0].cells.count; i++) {
      grid.headers[0].cells[i].style.backgroundBrush = PdfSolidBrush(headerBackgroundColor);
      grid.headers[0].cells[i].style.borders.all = PdfPens.transparent; // Quita las líneas de separación
      grid.headers[0].cells[i].style.font = fontTitulo;
    }
    for (var producto in productos) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = producto.codProducto.toString();
      row.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

      row.cells[1].value = producto.descripcion;
      row.cells[1].style.cellPadding = PdfPaddings(left: 5, top: 2, right: 0, bottom: 2);
      row.cells[2].value = producto.cant.toString();

      row.cells[2].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

      row.cells[3].value = producto.cantUnidad.toString();
      row.cells[3].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

      row.cells[4].value = producto.cantFraccion.toString();
      row.cells[4].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

      row.cells[5].value = '\$${producto.precioSinImpuesto.toString()}';
      row.cells[5].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

      row.cells[6].value = '\$${producto.total.toString()}';
      row.cells[6].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);
    }

    return grid;
  }

  PdfGrid _createTotalTable(Dato datosFactura) {
    final PdfGrid grid = PdfGrid();
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.overlap);

    // Define las columnas
    grid.columns.add(count: 2);

    // Añade las filas
    PdfGridRow row1 = grid.rows.add();
    row1.cells[0].value = 'Subtotal 15%:';
    row1.cells[1].value = '\$ ${datosFactura.baseIva}'; // Puedes poner el valor correspondiente aquí
    row1.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);
    PdfGridRow row2 = grid.rows.add();
    row2.cells[0].value = 'Subtotal 0%:';
    row2.cells[1].value = '\$ ${datosFactura.base0}';
    row2.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);
    PdfGridRow row3 = grid.rows.add();
    row3.cells[0].value = 'Subtotal sin impuestos:';
    row3.cells[1].value = '\$ ${datosFactura.monto}';
    row3.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);
    PdfGridRow row4 = grid.rows.add();
    row4.cells[0].value = 'IVA 15%:';
    row4.cells[1].value = '\$ ${datosFactura.iva}';
    row4.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);

    PdfGridRow row5 = grid.rows.add();
    row5.cells[0].value = '(-) Descuento Solidario 2% IVA:';
    row5.cells[0].style.font = fontTitulo;
    row5.cells[1].value = '\$ ${datosFactura.descuentos}';
    row5.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);

    PdfGridRow row6 = grid.rows.add();
    row6.cells[0].value = 'Valor Total:';
    row6.cells[0].style.font = fontTitulo;
    row6.cells[1].value = '\$ ${datosFactura.total}';
    row6.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.right, wordWrap: PdfWordWrapType.word);

    return grid;
  }

  PdfGrid _createInfoAdicionalTable(Dato datosFactura) {
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    final PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.overlap);

    // Define las columnas
    grid.columns.add(count: 1);

    // Añade las filas
    PdfGridRow row1 = grid.rows.add();
    row1.cells[0].value = 'Información Adicional';
    row1.cells[0].style.font = fontTitulo;
    row1.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center, wordWrap: PdfWordWrapType.word);

    PdfGridRow row2 = grid.rows.add();
    row2.cells[0].value = datosFactura.infoAdicional;

    return grid;
  }

  PdfGrid _createFormasPagoTable(Dato datosFactura) {
    final PdfGrid grid = PdfGrid();
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold);
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.overlap);

    // Define las columnas
    grid.columns.add(count: 4);

    // Añade las filas de encabezado
    grid.headers.add(1);
    grid.headers[0].cells[0].value = 'Forma de Pago';
    grid.headers[0].cells[1].value = 'Valor';
    grid.headers[0].cells[2].value = 'Plazo';
    grid.headers[0].cells[3].value = 'Tiempo';
    for (int i = 0; i < grid.headers[0].cells.count; i++) {
      grid.headers[0].cells[i].style.font = fontTitulo;
    }
    grid.columns[0].width = 100;
    grid.columns[1].width = 40;
    grid.columns[2].width = 40;
    grid.columns[3].width = 40;
    // Añade la fila con los datos
    PdfGridRow row1 = grid.rows.add();
    row1.cells[0].value = datosFactura.formaPago;
    row1.cells[1].value = '\$ ${datosFactura.total}';
    row1.cells[2].value = datosFactura.plazo.toString();
    row1.cells[3].value = datosFactura.unidad;

    return grid;
  }

  PdfGrid _createDeclaracionTable() {
    final PdfGrid grid = PdfGrid();
    final PdfFont fontTitulo = PdfStandardFont(PdfFontFamily.helvetica, 8);
    grid.style = PdfGridStyle(cellPadding: PdfPaddings(left: 5, top: 2, right: 5, bottom: 2), borderOverlapStyle: PdfBorderOverlapStyle.overlap);

    // Define las columnas
    grid.columns.add(count: 1);

    // Añade la declaración
    PdfGridRow row1 = grid.rows.add();
    row1.cells[0].value = '''Declaro que los datos consignados en el presente formulario son verídicos y autorizo en forma expresa a Grupo
Uscocovich a solicitar confirmación de los mismos, en cualquier fuente de información, incluidos los Buros de Crédito.\n
De igual forma autorizo a referir y/o publicar información crediticia a mi nombre o el de mi Representada en los Buros de
Crédito legalmente autorizados por la Superintendencia de Bancos.''';
    row1.cells[0].style.font = fontTitulo;
    return grid;
  }

  void _createSignatureLine(PdfPage page, double xPosition, double yPosition) {
    const double signatureLineWidth = 200.0;

    // Dibuja una línea para la firma
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0)), Offset(xPosition, yPosition), Offset(xPosition + signatureLineWidth, yPosition));

    // Agrega la etiqueta "Firma" centrada debajo de la línea
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);
    double textWidth = font.measureString('FIRMA').width;
    page.graphics.drawString('FIRMA', font, bounds: Rect.fromLTWH(xPosition + (signatureLineWidth - textWidth) / 2, yPosition + 5, textWidth, 20));
  }

  Future<Uint8List> _readImageData(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> _readImageData2(String path) async {
    final File file = File(path);
    return await file.readAsBytes();
  }

  Future<String> imprimir(String data) async {
    final image = img.Image(width: 400, height: 20);
    img.fill(image, color: img.ColorFloat16.rgb(255, 255, 255));

    drawBarcode(image, Barcode.code128(), data);
    final png = img.encodePng(image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/barcode.jpg';
    File(filePath).writeAsBytesSync(png);
    return filePath;
  }

  Future<PdfFont> loadCustomFont(Uint8List fontData) async {
    return PdfTrueTypeFont(fontData, 12);
  }
}
