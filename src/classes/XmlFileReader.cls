public class XmlFileReader {

    public static FINAL Set<String> charToExclude = new Set<String> {',','.'};
    public static String version;
    
    public static List<Violation_Code__c> parseViolations(XmlStreamReader reader) {
        List<Violation_Code__c> violations = new List<Violation_Code__c>();
        Boolean isSafeToGetNextXmlElement = true;
        String partDetails = '';
        String chapterDetails = '';
        String sectionDetails = '';
        String subSectionDetails = '';
        
        while(isSafeToGetNextXmlElement) {
            //System.debug('Get Event Type: ' + reader.getEventType());
            if(reader.getEventType() == XmlTag.START_ELEMENT) {
                System.debug('Get Local Name: ' + reader.getLocalName());
                if(String.isBlank(version) && reader.getLocalName() == 'section' &&  reader.getAttributeValue(null, 'class') == 'volume' && reader.getAttributeValue(null, 'type') == 'volume') {
                    version = reader.getAttributeValue(null, 'id');
                }
                
                if(reader.getLocalName() == 'h1' &&  reader.getAttributeValue(null, 'class') == 'part' && reader.getAttributeValue(null, 'type') == 'title') {
                    partDetails = parsePart(reader);
                    //System.debug('partDetails ===> ' + partDetails);
                    if(ignorePart(partDetails)) {
                        partDetails = null;
                    }
                    continue;
                }//If null, Part should be ignored. 
                else if(String.isNotBlank(partDetails)) {
                    if(reader.getLocalName() == 'h1' &&  reader.getAttributeValue(null, 'class') == 'chapter' && reader.getAttributeValue(null, 'type') == 'title') {
                        chapterDetails = parsePart(reader);
                        //System.debug('chapterDetails ===> ' + chapterDetails);
                    }
                    else if(reader.getLocalName() == 'h1' &&  reader.getAttributeValue(null, 'class') == 'level1') {
                        sectionDetails = parsePart(reader);
                        //System.debug('sectionDetails ===> ' + sectionDetails);
                    }
                    else if(reader.getLocalName() == 'h1' &&  (reader.getAttributeValue(null, 'class') == 'level2' || reader.getAttributeValue(null, 'class') == 'level3') 
                            && !sectionDetails.contains('DEFINITIONS')) {
                        subSectionDetails = parsePart(reader);
                        //System.debug('subSectionDetails ===> ' + subSectionDetails);
                        if (reader.hasNext()) {
                            reader.next();
                            violations.add(parseParagraph(reader, partDetails, chapterDetails, sectionDetails, subSectionDetails));
                        }
                    }
                }
            }
            
            // Check we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return violations;
    }
    
    public static String parsePart(XmlStreamReader reader) {
        List<Violation_Code__c> violations = new List<Violation_Code__c>();
        String partDetails = '';
        boolean isSafeToGetNextXmlElement = true;
        
        while(!(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'h1') && isSafeToGetNextXmlElement) {
            if(reader.getEventType() == XmlTag.CHARACTERS && String.isNotBlank(reader.getText())) {
                //System.debug('ParsePart: reader.getText() ===> ' + reader.getText());
                partDetails += reader.getText() + ' ';
            }
            // Check we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return partDetails;
    }
    
    //Parse subsection description
    public static Violation_Code__c parseParagraph(XmlStreamReader reader, String partDetails, String chapterDetails, String sectionDetails, String subSectionDetails) {
        String paraDetails = '';
        boolean isSafeToGetNextXmlElement = true;
        while(!(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'p') && isSafeToGetNextXmlElement) {
            if(reader.getEventType() == XmlTag.CHARACTERS && String.isNotBlank(reader.getText())) {
                //System.debug('Paragraph Details: reader.getText() ===> ' + reader.getText());
                if(String.isNotBlank(paraDetails) && !charToExclude.contains(reader.getText().trim())) {
                    paraDetails += ' ';
                }
                paraDetails += reader.getText();
            }
            // Check we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return createViolation(partDetails, chapterDetails, sectionDetails, subSectionDetails, paraDetails);
    }
    
    //Create a validation record
    public static Violation_Code__c createViolation(String partDetails, String chapterDetails, String sectionDetails, String subSectionDetails, String paraDetails) {
        Violation_Code__c newViolation = new Violation_Code__c();
        newViolation.Part__c = partDetails;
        newViolation.Chapter__c = chapterDetails;
        newViolation.Section__c = sectionDetails;
        newViolation.Subsection__c = subSectionDetails;
        newViolation.Description__c = paraDetails;
        newViolation.Status__c = 'Active';
        newViolation.Name = 'Violation ' + getSubsectionCode(subSectionDetails);
        newViolation.Version__c = version;
        
        //System.debug('newViolation ===> ' + newViolation);
        return newViolation;
    }
    
    //Custom label stores Parts that should be ignored
    public static Boolean ignorePart(String partDetails) {
        List<String> partsToIgnore = System.Label.PartsToIgnore.split(',');
        String part = partDetails.substring(partDetails.indexOf('Part'), partDetails.indexOf('—')).trim();
        return partsToIgnore.contains(part);
    }
    
    //Get section number of Subsection (Ex. 101.1)
    public static String getSubsectionCode(String myString) {
        Integer myIndex;
        Integer startIndex = 0;
        Boolean isNumbFound = false;
        
        for(myIndex = 0; myIndex < myString.length(); myIndex++) {
            String myChar = myString.subString(myIndex, myIndex + 1);
            
            if(!isNumbFound && myChar.isNumeric()){
                startIndex = myIndex;
                isNumbFound = true;
            }else if(isNumbFound && (myChar.isAlpha() || String.isBlank(myChar))) {
                break;
            }
        }
        return myString.substring(startIndex, myIndex);
    }
}