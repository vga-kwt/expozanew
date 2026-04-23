/**
 * Formats an address string (which may be JSON) into a readable format
 * @param address - Address string (can be JSON string or plain string)
 * @returns Formatted address string
 */
export function formatAddress(address: string | null | undefined): string {
    if (!address) {
        return 'Not provided';
    }

    // Try to parse as JSON first
    try {
        const addressObj = typeof address === 'string' ? JSON.parse(address) : address;
        
        // If it's an object, format it nicely
        if (typeof addressObj === 'object' && addressObj !== null) {
            const parts: string[] = [];
            
            if (addressObj.full_name) {
                parts.push(addressObj.full_name);
            }
            
            if (addressObj.line_1) {
                parts.push(addressObj.line_1);
            }
            
            if (addressObj.line_2) {
                parts.push(addressObj.line_2);
            }
            
            // City, State, Country
            const locationParts: string[] = [];
            if (addressObj.city) locationParts.push(addressObj.city);
            if (addressObj.state) locationParts.push(addressObj.state);
            if (addressObj.country) locationParts.push(addressObj.country);
            
            if (locationParts.length > 0) {
                parts.push(locationParts.join(', '));
            }
            
            if (addressObj.pincode) {
                parts.push(addressObj.pincode);
            }
            
            if (addressObj.phone) {
                parts.push(`Phone: ${addressObj.phone}`);
            }
            
            return parts.join('\n');
        }
    } catch (e) {
        // If parsing fails, it's probably already a formatted string
        // Return as is
    }

    // If it's not JSON or parsing failed, return the string as is
    return address;
}

